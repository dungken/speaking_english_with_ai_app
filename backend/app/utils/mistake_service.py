import uuid
import logging
from typing import Dict, Any, List, Optional
from datetime import datetime, timedelta
from bson import ObjectId

from app.config.database import db

logger = logging.getLogger(__name__)

class MistakeService:
    """
    Service for processing, storing, and managing language mistakes.
    
    This service provides functionality to:
    1. Extract mistakes from feedback
    2. Store unique mistakes in the database
    3. Calculate next practice dates using spaced repetition
    4. Retrieve mistakes for practice
    5. Update mistake status after practice
    """
    
    async def process_feedback_for_mistakes(
        self,
        user_id: str,
        transcription: str,
        detailed_feedback: Dict[str, Any],
        context: Optional[Dict[str, Any]] = None
    ) -> int:
        """
        Extract mistakes from detailed feedback and store them.
        
        Args:
            user_id: ID of the user
            transcription: Original transcription text
            detailed_feedback: Detailed feedback from Gemini
            context: Optional conversation context
            
        Returns:
            Number of mistakes processed
            
        Raises:
            Exception: If there are issues with extraction or storage
        """
        try:
            # Extract grammar mistakes
            grammar_mistakes = []
            for issue in detailed_feedback.get("grammar_issues", []):
                # Only process significant issues (severity > 2)
                if issue.get("severity", 3) > 2:
                    mistake = {
                        "user_id": ObjectId(user_id),
                        "type": "GRAMMAR",
                        "original_text": issue.get("issue", ""),
                        "correction": issue.get("correction", ""),
                        "explanation": issue.get("explanation", ""),
                        "severity": issue.get("severity", 3),
                        "context": self._extract_context(transcription, issue.get("issue", "")),
                        "situation_context": self._extract_situation_context(context),
                        "created_at": datetime.utcnow(),
                        "last_occurred": datetime.utcnow(),
                        "frequency": 1,
                        "last_practiced": None,
                        "practice_count": 0,
                        "success_count": 0,
                        "next_practice_date": self._calculate_next_practice(0, False),
                        "in_drill_queue": True,
                        "is_learned": False,
                        "mastery_level": 0,
                        "status": "NEW"
                    }
                    grammar_mistakes.append(mistake)
            
            # Extract vocabulary mistakes
            vocab_mistakes = []
            for issue in detailed_feedback.get("vocabulary_issues", []):
                mistake = {
                    "user_id": ObjectId(user_id),
                    "type": "VOCABULARY",
                    "original_text": issue.get("original", ""),
                    "correction": issue.get("better_alternative", ""),
                    "explanation": issue.get("reason", ""),
                    "example_usage": issue.get("example_usage", ""),
                    "context": self._extract_context(transcription, issue.get("original", "")),
                    "situation_context": self._extract_situation_context(context),
                    "created_at": datetime.utcnow(),
                    "last_occurred": datetime.utcnow(),
                    "frequency": 1,
                    "last_practiced": None,
                    "practice_count": 0,
                    "success_count": 0,
                    "next_practice_date": self._calculate_next_practice(0, False),
                    "in_drill_queue": True,
                    "is_learned": False,
                    "mastery_level": 0,
                    "status": "NEW"
                }
                vocab_mistakes.append(mistake)
            
            # Combine all mistakes
            all_mistakes = grammar_mistakes + vocab_mistakes
            
            # Store non-duplicate mistakes
            stored_ids = await self._store_unique_mistakes(user_id, all_mistakes)
            
            return len(stored_ids)
            
        except Exception as e:
            logger.error(f"Error processing mistakes: {str(e)}")
            raise
    
    def _extract_context(self, transcription: str, text: str) -> str:
        """
        Extract text surrounding the mistake for context.
        
        Args:
            transcription: Full transcription text
            text: The specific text with the mistake
            
        Returns:
            Context string with mistake highlighted
        """
        if not text or text not in transcription:
            return transcription
        
        # Find position of the mistake
        pos = transcription.find(text)
        
        # Get surrounding text (50 chars before and after)
        start = max(0, pos - 50)
        end = min(len(transcription), pos + len(text) + 50)
        
        # Create context with highlighted mistake
        context = transcription[start:end]
        highlighted = context.replace(text, f"[{text}]")
        
        return highlighted
    
    def _extract_situation_context(self, context: Optional[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        """
        Extract relevant situation info from context.
        
        Args:
            context: Conversation context
            
        Returns:
            Dictionary with relevant context information
        """
        if not context:
            return None
        
        return {
            "user_role": context.get("user_role"),
            "ai_role": context.get("ai_role"),
            "situation": context.get("situation")
        }
    
    def _calculate_next_practice(self, practice_count: int, was_successful: bool) -> datetime:
        """
        Calculate next practice date using spaced repetition.
        
        Args:
            practice_count: Number of times this mistake has been practiced
            was_successful: Whether the last practice was successful
            
        Returns:
            Datetime for next practice
        """
        now = datetime.utcnow()
        
        # New mistake - practice soon
        if practice_count == 0:
            return now + timedelta(hours=2)
        
        # Failed practice - retry soon
        if not was_successful:
            return now + timedelta(hours=4)
        
        # Successful practice - gradually increase interval
        interval_days = min(2 ** practice_count, 30)  # Cap at 30 days
        return now + timedelta(days=interval_days)
    
    async def _store_unique_mistakes(self, user_id: str, mistakes: List[Dict[str, Any]]) -> List[str]:
        """
        Store mistakes while handling duplicates.
        
        Args:
            user_id: ID of the user
            mistakes: List of mistakes to store
            
        Returns:
            List of stored mistake IDs
        """
        stored_ids = []
        
        for mistake in mistakes:
            # Skip empty mistakes
            if not mistake.get("original_text") or not mistake.get("correction"):
                continue
                
            # Check for existing similar mistake
            existing = None
            try:
                existing = await db.mistakes.find_one({
                    "user_id": ObjectId(user_id),
                    "type": mistake["type"],
                    "original_text": mistake["original_text"],
                    "status": {"$ne": "MASTERED"}
                })
            except Exception as e:
                logger.error(f"Error finding existing mistake: {str(e)}")
                continue
            
            if existing:
                # Update existing mistake (increase frequency)
                try:
                    await db.mistakes.update_one(
                        {"_id": existing["_id"]},
                        {
                            "$inc": {"frequency": 1},
                            "$set": {"last_occurred": datetime.utcnow()}
                        }
                    )
                    stored_ids.append(str(existing["_id"]))
                except Exception as e:
                    logger.error(f"Error updating existing mistake: {str(e)}")
            else:
                # Insert new mistake
                try:
                    result = await db.mistakes.insert_one(mistake)
                    stored_ids.append(str(result.inserted_id))
                except Exception as e:
                    logger.error(f"Error inserting new mistake: {str(e)}")
        
        return stored_ids
    
    async def get_practice_items(self, user_id: str, limit: int = 5) -> List[Dict[str, Any]]:
        """
        Get mistakes due for practice.
        
        Args:
            user_id: ID of the user
            limit: Maximum number of mistakes to return
            
        Returns:
            List of mistakes due for practice
        """
        now = datetime.utcnow()
        
        try:
            # Get mistakes due for practice
            cursor = db.mistakes.find({
                "user_id": ObjectId(user_id),
                "next_practice_date": {"$lte": now},
                "status": {"$ne": "MASTERED"},
                "in_drill_queue": True
            }).sort([
                ("frequency", -1),  # Most frequent first
                ("severity", -1)    # Most severe next
            ]).limit(limit)
            
            mistakes = await cursor.to_list(length=limit)
            
            # Transform into practice exercises
            exercises = []
            for mistake in mistakes:
                exercise = {
                    "mistake_id": str(mistake["_id"]),
                    "type": mistake["type"],
                    "practice_prompt": self._generate_practice_prompt(mistake),
                    "original_text": mistake["original_text"],
                    "context": mistake["context"],
                    "correction": mistake["correction"],
                    "explanation": mistake["explanation"]
                }
                
                # Add example usage for vocabulary
                if mistake["type"] == "VOCABULARY" and "example_usage" in mistake:
                    exercise["example_usage"] = mistake["example_usage"]
                    
                exercises.append(exercise)
            
            return exercises
            
        except Exception as e:
            logger.error(f"Error getting practice items: {str(e)}")
            return []
    
    async def record_practice_result(
        self, 
        mistake_id: str, 
        user_id: str,
        was_successful: bool, 
        user_answer: str
    ) -> Dict[str, Any]:
        """
        Record the result of practicing a mistake.
        
        Args:
            mistake_id: ID of the mistake
            user_id: ID of the user
            was_successful: Whether the practice was successful
            user_answer: User's answer during practice
            
        Returns:
            Updated mistake information
            
        Raises:
            ValueError: If mistake not found
        """
        try:
            # Get the mistake
            mistake = await db.mistakes.find_one({
                "_id": ObjectId(mistake_id), 
                "user_id": ObjectId(user_id)
            })
            
            if not mistake:
                raise ValueError(f"Mistake not found: {mistake_id}")
            
            # Update practice stats
            practice_count = mistake.get("practice_count", 0) + 1
            success_count = mistake.get("success_count", 0) + (1 if was_successful else 0)
            
            # Calculate mastery level (0-10)
            mastery_level = min(10, int((success_count / practice_count) * 10)) if practice_count > 0 else 0
            
            # Determine status
            status = "MASTERED" if mastery_level >= 8 else "LEARNING"
            is_learned = status == "MASTERED"
            
            # Calculate next practice date
            next_practice = self._calculate_next_practice(practice_count, was_successful)
            
            # Update mistake
            await db.mistakes.update_one(
                {"_id": ObjectId(mistake_id)},
                {
                    "$set": {
                        "practice_count": practice_count,
                        "success_count": success_count,
                        "last_practiced": datetime.utcnow(),
                        "user_answer": user_answer,
                        "mastery_level": mastery_level,
                        "status": status,
                        "is_learned": is_learned,
                        "in_drill_queue": not is_learned,
                        "next_practice_date": next_practice
                    }
                }
            )
            
            # Get updated mistake
            updated_mistake = await db.mistakes.find_one({"_id": ObjectId(mistake_id)})
            
            if not updated_mistake:
                raise ValueError(f"Updated mistake not found: {mistake_id}")
                
            # Convert ObjectId to string
            updated_mistake["_id"] = str(updated_mistake["_id"])
            updated_mistake["user_id"] = str(updated_mistake["user_id"])
            
            # Add feedback
            updated_mistake["feedback"] = self._generate_practice_feedback(updated_mistake, was_successful)
            
            return updated_mistake
            
        except Exception as e:
            logger.error(f"Error recording practice result: {str(e)}")
            raise
    
    def _generate_practice_prompt(self, mistake: Dict[str, Any]) -> str:
        """
        Generate a prompt for practicing this mistake.
        
        Args:
            mistake: Mistake data
            
        Returns:
            Practice prompt string
        """
        if mistake["type"] == "GRAMMAR":
            return f"Correct the grammar in this sentence: \"{mistake['context']}\""
        
        elif mistake["type"] == "VOCABULARY":
            return f"Improve this sentence by using a better word or phrase for '{mistake['original_text']}': \"{mistake['context']}\""
        
        return f"Practice this mistake: {mistake['original_text']}"
    
    def _generate_practice_feedback(self, mistake: Dict[str, Any], was_successful: bool) -> str:
        """
        Generate feedback for practice attempt.
        
        Args:
            mistake: Mistake data
            was_successful: Whether the practice was successful
            
        Returns:
            Feedback string
        """
        if was_successful:
            return f"Great job! You've correctly used '{mistake['correction']}' instead of '{mistake['original_text']}'."
        else:
            return f"Keep practicing! Remember to use '{mistake['correction']}' instead of '{mistake['original_text']}'. {mistake['explanation']}" 