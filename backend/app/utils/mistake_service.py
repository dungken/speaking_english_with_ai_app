import uuid
import logging
from typing import Dict, Any, List, Optional
from datetime import datetime, timedelta
from bson import ObjectId

from app.config.database import db

logger = logging.getLogger(__name__)

class MistakeStatistics:
    """
    Container for mistake statistics as shown in the class diagram.
    """
    def __init__(
        self,
        total_count: int = 0,
        mastered_count: int = 0,
        learning_count: int = 0,
        new_count: int = 0,
        type_distribution: Dict[str, int] = None,
        due_for_practice: int = 0,
        mastery_percentage: float = 0.0
    ):
        self.total_count = total_count
        self.mastered_count = mastered_count
        self.learning_count = learning_count
        self.new_count = new_count
        self.type_distribution = type_distribution or {}
        self.due_for_practice = due_for_practice
        self.mastery_percentage = mastery_percentage
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for API response"""
        return {
            "total_count": self.total_count,
            "mastered_count": self.mastered_count, 
            "learning_count": self.learning_count,
            "new_count": self.new_count,
            "type_distribution": self.type_distribution,
            "due_for_practice": self.due_for_practice,
            "mastery_percentage": self.mastery_percentage
        }

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
    
    def process_feedback_for_mistakes(
        self,
        user_id: str,
        transcription: str,
        feedback: Dict[str, Any],
        context: Optional[Dict[str, Any]] = None
    ) -> int:
        """
        Extract mistakes from feedback and store them.
        
        Args:
            user_id: ID of the user
            transcription: Original transcription text
            feedback: Feedback data (either raw object or from database)
            context: Optional conversation context
            
        Returns:
            Number of mistakes processed
        """
        try:
            # Handle different feedback structures
            detailed_feedback = {}
            if isinstance(feedback, dict):
                if "detailed_feedback" in feedback:
                    detailed_feedback = feedback.get("detailed_feedback", {})
                else:
                    # Directly using the object as detailed feedback
                    detailed_feedback = feedback
                    
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
            stored_ids = self._store_unique_mistakes(user_id, all_mistakes)
            
            return len(stored_ids)
            
        except Exception as e:
            logger.error(f"Error processing mistakes: {str(e)}")
            raise
    
    def get_unmastered_mistakes(self, user_id: str) -> List[Dict[str, Any]]:
        """
        Get all unmastered mistakes for a user.
        
        This method matches the class diagram's getUnmasteredMistakes method.
        
        Args:
            user_id: ID of the user
            
        Returns:
            List of unmastered mistakes
        """
        try:
            # Fetch unmastered mistakes
            cursor = db.mistakes.find({
                "user_id": ObjectId(user_id),
                "status": {"$ne": "MASTERED"}
            }).sort("next_practice_date", 1)
            
            # Convert to list and format IDs
            mistakes = list(cursor)
            for mistake in mistakes:
                mistake["_id"] = str(mistake["_id"])
                mistake["user_id"] = str(mistake["user_id"])
            
            return mistakes
            
        except Exception as e:
            logger.error(f"Error fetching unmastered mistakes: {str(e)}")
            return []
    
    def get_mistakes_for_practice(self, user_id: str, limit: int = 5) -> List[Dict[str, Any]]:
        """
        Retrieve mistakes for practice.
        
        This method matches the class diagram's getMistakesForPractice method.
        
        Args:
            user_id: ID of the user
            limit: Maximum number of mistakes to return
            
        Returns:
            List of mistakes for practice
        """
        now = datetime.utcnow()
        
        try:
            # Fetch practice-due mistakes
            cursor = db.mistakes.find({
                "user_id": ObjectId(user_id),
                "in_drill_queue": True,
                "next_practice_date": {"$lte": now}
            }).sort("next_practice_date", 1).limit(limit)
            
            mistakes = list(cursor)
            
            # Transform into practice exercises
            return [self._transform_to_practice_item(mistake) for mistake in mistakes]
            
        except Exception as e:
            logger.error(f"Error fetching practice items: {str(e)}")
            return []
    
    def get_mistake_statistics(self, user_id: str) -> MistakeStatistics:
        """
        Get statistics about a user's mistakes.
        
        This method matches the class diagram's getMistakeStatistics method.
        
        Args:
            user_id: ID of the user
            
        Returns:
            MistakeStatistics object with statistics
        """
        try:
            now = datetime.utcnow()
            
            # Get counts by status
            total_count = db.mistakes.count_documents({"user_id": ObjectId(user_id)})
            mastered_count = db.mistakes.count_documents({"user_id": ObjectId(user_id), "status": "MASTERED"})
            learning_count = db.mistakes.count_documents({"user_id": ObjectId(user_id), "status": "LEARNING"})
            new_count = db.mistakes.count_documents({"user_id": ObjectId(user_id), "status": "NEW"})
            
            # Get type distribution
            grammar_count = db.mistakes.count_documents({"user_id": ObjectId(user_id), "type": "GRAMMAR"})
            vocab_count = db.mistakes.count_documents({"user_id": ObjectId(user_id), "type": "VOCABULARY"})
            
            # Get due for practice
            due_count = db.mistakes.count_documents({
                "user_id": ObjectId(user_id), 
                "next_practice_date": {"$lte": now},
                "status": {"$ne": "MASTERED"}
            })
            
            # Calculate mastery percentage
            mastery_percentage = 0
            if total_count > 0:
                mastery_percentage = (mastered_count / total_count) * 100
            
            return MistakeStatistics(
                total_count=total_count,
                mastered_count=mastered_count,
                learning_count=learning_count,
                new_count=new_count,
                type_distribution={
                    "GRAMMAR": grammar_count,
                    "VOCABULARY": vocab_count
                },
                due_for_practice=due_count,
                mastery_percentage=mastery_percentage
            )
            
        except Exception as e:
            logger.error(f"Error getting mistake statistics: {str(e)}")
            return MistakeStatistics()
    
    def update_after_practice(
        self,
        mistake_id: str, 
        result: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Update mistake after practice.
        
        This method matches the class diagram's updateAfterPractice method.
        
        Args:
            mistake_id: ID of the mistake
            result: Practice result data including user_id, was_successful, and user_answer
            
        Returns:
            Updated mistake information
        """
        try:
            user_id = result.get("user_id")
            was_successful = result.get("was_successful", False)
            user_answer = result.get("user_answer", "")
            
            # Look up mistake
            mistake = db.mistakes.find_one({
                "_id": ObjectId(mistake_id),
                "user_id": ObjectId(user_id)
            })
            
            if not mistake:
                return {"error": "Mistake not found"}
            
            # Update practice metrics
            practice_count = mistake.get("practice_count", 0) + 1
            success_count = mistake.get("success_count", 0)
            
            if was_successful:
                success_count += 1
            
            # Calculate mastery level (0-100)
            if practice_count > 0:
                mastery_percentage = (success_count / practice_count) * 100
            else:
                mastery_percentage = 0
            
            # Determine status
            status = mistake.get("status", "NEW")
            is_learned = mistake.get("is_learned", False)
            
            if mastery_percentage >= 80 and practice_count >= 3:
                status = "MASTERED"
                is_learned = True
            elif mastery_percentage >= 50:
                status = "LEARNING"
                is_learned = True
                
            # Calculate next practice date
            next_practice_date = self._calculate_next_practice(practice_count, was_successful)
            
            # Update in database
            db.mistakes.update_one(
                {"_id": ObjectId(mistake_id)},
                {
                    "$set": {
                        "practice_count": practice_count,
                        "success_count": success_count,
                        "last_practiced": datetime.utcnow(),
                        "next_practice_date": next_practice_date,
                        "mastery_level": mastery_percentage,
                        "status": status,
                        "is_learned": is_learned,
                        "last_answer": user_answer
                    }
                }
            )
            
            # Get updated mistake
            updated_mistake = db.mistakes.find_one({"_id": ObjectId(mistake_id)})
            
            if not updated_mistake:
                raise ValueError(f"Updated mistake not found: {mistake_id}")
            
            # Convert ObjectId to string
            updated_mistake["_id"] = str(updated_mistake["_id"])
            updated_mistake["user_id"] = str(updated_mistake["user_id"])
            
            # Add feedback
            updated_mistake["feedback"] = self._generate_practice_feedback(updated_mistake, was_successful)
            
            return updated_mistake
                
        except Exception as e:
            logger.error(f"Error updating after practice: {str(e)}")
            raise
    
    def create_practice_session(
        self, 
        user_id: str, 
        mistakes: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """
        Create a new practice session.
        
        This method matches the class diagram's createPracticeSession method.
        
        Args:
            user_id: ID of the user
            mistakes: List of mistakes to include in the session
            
        Returns:
            Created practice session
        """
        try:
            # Create practice session record
            session = {
                "_id": ObjectId(),
                "user_id": ObjectId(user_id),
                "started_at": datetime.utcnow(),
                "completed_at": None,
                "mistakes_practiced": [],
                "created_at": datetime.utcnow()
            }
            
            # Insert session
            db.practice_sessions.insert_one(session)
            
            # Format for response
            session["_id"] = str(session["_id"])
            session["user_id"] = str(session["user_id"])
            session["mistake_ids"] = [m.get("_id") for m in mistakes]
            
            return session
            
        except Exception as e:
            logger.error(f"Error creating practice session: {str(e)}")
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
    
    def _calculate_next_practice_date(self, practice_count: int, was_successful: bool) -> datetime:
        """
        Calculate next practice date using spaced repetition.
        
        This method matches the class diagram's calculateNextPracticeDate method.
        
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
    
    # Alias for backward compatibility
    _calculate_next_practice = _calculate_next_practice_date
    
    def _store_unique_mistakes(self, user_id: str, mistakes: List[Dict[str, Any]]) -> List[str]:
        """
        Store mistakes while handling duplicates.
        
        This method matches the class diagram's storeUniqueMistakes method.
        
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
                existing = db.mistakes.find_one({
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
                    db.mistakes.update_one(
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
                    result = db.mistakes.insert_one(mistake)
                    stored_ids.append(str(result.inserted_id))
                except Exception as e:
                    logger.error(f"Error inserting new mistake: {str(e)}")
        
        return stored_ids
    
    def _transform_to_practice_item(self, mistake: Dict[str, Any]) -> Dict[str, Any]:
        """
        Transform a mistake into a practice item.
        
        Args:
            mistake: The mistake to transform
            
        Returns:
            Practice item
        """
        # Convert ObjectId to string
        mistake_copy = mistake.copy()
        mistake_copy["_id"] = str(mistake_copy["_id"]) 
        mistake_copy["user_id"] = str(mistake_copy["user_id"])
        
        # Add practice prompt
        mistake_copy["practice_prompt"] = self._generate_practice_prompt(mistake)
        
        return mistake_copy
    
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
    
    def extract_and_store_mistakes(
        self,
        user_id: str,
        transcription: str,
        feedback: Dict[str, Any]
    ) -> int:
        """
        Extract mistakes from a feedback record and store them.
        
        This method is a specialized version of process_feedback_for_mistakes
        designed to work with direct feedback database records.
        
        Args:
            user_id: ID of the user
            transcription: Original transcription text
            feedback: Feedback record from database
            
        Returns:
            Number of mistakes processed
        """
        return self.process_feedback_for_mistakes(user_id, transcription, feedback) 