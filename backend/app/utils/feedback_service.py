import json
import logging
from typing import Dict, Any, Optional, List, Tuple, Union
from datetime import datetime
from bson import ObjectId

# Import Gemini client
from app.utils.gemini import generate_response
from app.config.database import db
from app.models.feedback import Feedback
from app.models.results.feedback_result import FeedbackResult, DetailedFeedback

logger = logging.getLogger(__name__)

class FeedbackService:
    """
    Service for generating language feedback using Gemini API.
    
    This service provides functionality to:
    1. Generate dual feedback (user-friendly and detailed) for a user's speech
    2. Build prompts for Gemini that ask for both types of feedback
    3. Parse and validate the response from Gemini
    4. Store feedback in the database
    """
    
    def generate_dual_feedback(
        self, 
        transcription: str, 
        context: Optional[Dict[str, Any]] = None
    ) -> FeedbackResult:
        """
        Generate both user-friendly and detailed feedback in one call to Gemini.
        
        Args:
            transcription: Transcribed text from the user's speech
            context: Optional conversation context information
            
        Returns:
            FeedbackResult containing user_feedback and detailed_feedback
        """
        try:
            # Build prompt for dual feedback
            prompt = self._build_dual_feedback_prompt(transcription, context)
 
    
            # Call Gemini API   
            gemini_response = generate_response(prompt)
                       # Clean the response text by removing markdown formatting
            cleaned_text = gemini_response.strip()
            if cleaned_text.startswith("```json"):
                cleaned_text = cleaned_text[7:]  # Remove ```json prefix
            if cleaned_text.endswith("```"):
                cleaned_text = cleaned_text[:-3]  # Remove ``` suffix
            cleaned_text = cleaned_text.strip()
            # parse the json
            
  
            # Parse JSON response
            
            try:
                response_data = json.loads(cleaned_text)
                
                # Validate the response structure
                if not isinstance(response_data, dict):
                    raise ValueError("Gemini API response is not a valid JSON object")
                
                if "user_feedback" not in response_data:
                    raise ValueError("Missing 'user_feedback' field in Gemini response")
                    
                if "detailed_feedback" not in response_data:
                    raise ValueError("Missing 'detailed_feedback' field in Gemini response")
                
                # Create and return FeedbackResult
                return FeedbackResult(
                    user_feedback=response_data.get("user_feedback", ""),
                    detailed_feedback=response_data.get("detailed_feedback", {})
                )
                
            except json.JSONDecodeError as e:
                logger.error(f"Failed to parse Gemini response as JSON: {e}")
                logger.debug(f"Raw response: {cleaned_text}")
                # Fall back to basic feedback
                return self._generate_fallback_feedback(transcription)
                
        except Exception as e:
            logger.error(f"Error generating feedback: {str(e)}")
            return self._generate_fallback_feedback(transcription)
    
    def store_feedback(
        self, 
        user_id: str, 
        feedback_data: Union[FeedbackResult, Dict[str, Any]], 
        user_message_id: Optional[str] = None, 
        transcription: Optional[str] = None
    ) -> str:
        """
        Store feedback in the database.
        
        Args:
            user_id: ID of the user who received the feedback
            feedback_data: Feedback data to store (FeedbackResult or dict)
            conversation_id: Optional ID of the associated conversation
            transcription: Optional transcription text
            
        Returns:
            ID of the stored feedback
        """
        try:
            # Validate required parameters
            if not user_id:
                logger.warning("Missing user_id for feedback storage")
                user_id = "unknown_user"  # Fallback value
            
            # Convert string IDs to ObjectIds
            try:
                user_object_id = ObjectId(user_id)
            except Exception as e:
                logger.warning(f"Invalid user_id format: {user_id}. Using generic ObjectId.")
                user_object_id = ObjectId()
            
            target_id = ObjectId(user_message_id) if user_message_id else ObjectId()
            
            # Process feedback data based on type
            if isinstance(feedback_data, FeedbackResult):
                user_feedback = feedback_data.user_feedback
                detailed_feedback = feedback_data.detailed_feedback.to_dict()
            else:
                user_feedback = feedback_data.get("user_feedback", "")
                detailed_feedback = feedback_data.get("detailed_feedback", {})
                
            # Access the detailed feedback safely
            if not isinstance(detailed_feedback, dict):
                detailed_feedback = {}
            
            # Create feedback model with explicit user_id and transcription
            feedback = Feedback(
                user_id=user_object_id,
                target_id=target_id,
                target_type="message" if user_message_id else "conversation",
                transcription=transcription,
                user_feedback=user_feedback,
                grammar_issues=detailed_feedback.get("grammar_issues", []),
                vocabulary_issues=detailed_feedback.get("vocabulary_issues", [])
            )
            
            # Insert feedback into database
            result = db.feedback.insert_one(feedback.to_dict())
            
            # If associated with a conversation, update the conversation record
            if user_message_id:
                db.conversations.update_one(
                    {"_id": ObjectId(user_message_id)},
                    {"$push": {"feedback_ids": str(result.inserted_id)}}
                )
            
            # Return the feedback ID as a string
            return str(result.inserted_id)
                
        except Exception as e:
            logger.error(f"Error storing feedback: {str(e)}")
            raise Exception(f"Failed to store feedback: {str(e)}")
    
    def _build_dual_feedback_prompt(
        self, 
        transcription: str, 
        context: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Build prompt for generating both user and detailed feedback.
        
        Args:
            transcription: Transcribed text from the user's speech
            context: Optional conversation context information
            
        Returns:
            Formatted prompt string for Gemini
        """
        prompt = """
        You are an expert English teacher  providing feedback on a student's speech.
        """
        
        # Add context if available
        if context:
            prompt += f"""
            Context:
            - User role: {context.get('user_role', 'Student')}
            - AI role: {context.get('ai_role', 'Teacher')}
            - Situation: {context.get('situation', 'General conversation')}
            
            Previous exchanges:
            {context.get('previous_exchanges', 'No previous exchanges')}
            """
        
        # Add transcription
        prompt += f"""
        Student's speech: "{transcription}"
        
        Generate two types of feedback in JSON format:
        
        1. user_feedback: Hãy đưa ra nhận xét và hướng dẫn như một người bản xứ nói tiếng Anh có thể sử dụng tiếng Việt để giải thích:
              -Phân tích câu trả lời của người học và chỉ ra các lỗi về ngữ pháp và từ vựng.
              -Cung cấp gợi ý hoặc ví dụ về cách dùng từ/cụm từ tốt hơn để diễn đạt tự nhiên hơn
              -Đưa ra phiên bản câu hoàn chỉnh hơn, sát với câu gốc nhưng đúng hơn, phù hợp với trình độ người học.
              -Phân tích cấu trúc ngữ pháp (mental model) của câu ví dụ bạn đưa ra: chỉ ra chủ ngữ, động từ, bổ ngữ, cách dùng mệnh đề phụ (nếu có), và chức năng giao tiếp của từng phần trong câu. ( nhớ so sánh  với câu gốc của người học)
              -Nếu câu trả lời của người học ngắn, chưa rõ ý, hoặc sai lệch hoàn toàn, hãy đưa ra một câu trả lời mẫu đơn giản hơn để họ có thể hình dung cách diễn đạt đúng, nhưng không nâng cấp quá xa so với trình độ hiện tại của họ.
        2. detailed_feedback: Structured, detailed analysis with these exact fields:
          - grammar_issues: Array of objects with fields:
            - issue: The exact problematic text
            - correction: How it should be corrected
            - explanation: Why this is an issue
            - severity: Number 1-5 (1=minor, 5=major)
          
          - vocabulary_issues: Array of objects with fields:
            - original: The word or phrase used
            - better_alternative: A better word or phrase
            - reason: Why the alternative is better
            - example_usage: Example sentence using the better alternative
        
        Return ONLY the JSON object with these two fields, properly formatted. Limit to at most 3 grammar issues and 3 vocabulary issues, focusing on the most important ones.
        """
        return prompt
    
    def _generate_fallback_feedback(self, transcription: str) -> FeedbackResult:
        """
        Generate fallback feedback when the API call fails.
        
        Args:
            transcription: Transcribed text from user's speech
            
        Returns:
            Basic FeedbackResult with minimal content
        """
        return FeedbackResult(
            user_feedback="Thank you for your response. I had trouble analyzing it in detail, but please continue practicing.",
            detailed_feedback={
                "grammar_issues": [],
                "vocabulary_issues": []
            }
        ) 