import json
import logging
from typing import Dict, Any, Optional, List, Tuple
from datetime import datetime
from bson import ObjectId

# Import Gemini client
from app.utils.gemini import generate_response
from app.config.database import db
from app.models.feedback import Feedback

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
    ) -> Dict[str, Any]:
        """
        Generate both user-friendly and detailed feedback in one call to Gemini.
        
        Args:
            transcription: Transcribed text from the user's speech
            context: Optional conversation context information
            
        Returns:
            Dictionary containing user_feedback and detailed_feedback
            
        Raises:
            Exception: If there are issues with the API call or response parsing
        """
        try:
            # Build prompt for dual feedback
            prompt = self._build_dual_feedback_prompt(transcription, context)
            
            # Call Gemini API
            response = generate_response(prompt)
            
            # Parse JSON response
            try:
                response_data = json.loads(response)
                
                # Validate the response structure
                if not isinstance(response_data, dict):
                    raise ValueError("Gemini API response is not a valid JSON object")
                
                if "user_feedback" not in response_data:
                    raise ValueError("Missing 'user_feedback' field in Gemini response")
                    
                if "detailed_feedback" not in response_data:
                    raise ValueError("Missing 'detailed_feedback' field in Gemini response")
                
                # Return both feedback types
                return {
                    "user_feedback": response_data.get("user_feedback", ""),
                    "detailed_feedback": response_data.get("detailed_feedback", {})
                }
                
            except json.JSONDecodeError as e:
                logger.error(f"Failed to parse Gemini response as JSON: {e}")
                logger.debug(f"Raw response: {response}")
                # Fall back to basic feedback
                return self._generate_fallback_feedback(transcription)
                
        except Exception as e:
            logger.error(f"Error generating feedback: {str(e)}")
            return self._generate_fallback_feedback(transcription)
    
    def store_feedback(self, user_id: str, feedback_data: Dict[str, Any], conversation_id: Optional[str] = None) -> str:
        """
        Store feedback in the database.
        
        Args:
            user_id: ID of the user who received the feedback
            feedback_data: Feedback data to store
            conversation_id: Optional ID of the associated conversation
            
        Returns:
            ID of the stored feedback
            
        Raises:
            StorageError: If database storage fails
        """
        try:
            # Convert string IDs to ObjectIds
            user_object_id = ObjectId(user_id)
            target_id = ObjectId(conversation_id) if conversation_id else ObjectId()
            
            # Create feedback model
            feedback = Feedback(
                target_id=target_id,
                target_type="conversation" if conversation_id else "standalone",
                user_feedback=feedback_data.get("user_feedback", ""),
                grammar_issues=feedback_data.get("detailed_feedback", {}).get("grammar_issues", []),
                vocabulary_issues=feedback_data.get("detailed_feedback", {}).get("vocabulary_issues", [])
            )
            
            # Insert feedback into database
            result = db.feedback.insert_one(feedback.to_dict())
            
            # If associated with a conversation, update the conversation record
            if conversation_id:
                db.conversations.update_one(
                    {"_id": ObjectId(conversation_id)},
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
        You are an expert English teacher providing feedback on a student's speech.
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
        
        1. user_feedback: Friendly, encouraging feedback that focuses on 1-2 key improvements and at least one positive aspect. This should be written in natural language, ready to show to the user.
        
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
    
    def _generate_fallback_feedback(self, transcription: str) -> Dict[str, Any]:
        """
        Generate fallback feedback when the API call fails.
        
        Args:
            transcription: Transcribed text from user's speech
            
        Returns:
            Basic feedback dictionary
        """
        return {
            "user_feedback": "Thank you for your response. I had trouble analyzing it in detail, but please continue practicing.",
            "detailed_feedback": {
                "grammar_issues": [],
                "vocabulary_issues": []
            }
        } 