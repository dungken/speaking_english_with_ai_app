from datetime import datetime, timedelta
from bson import ObjectId
from typing import Optional, Dict, Any

class Mistake:
    """
    Model representing a language mistake made by a user.
    
    Attributes:
        _id: Unique identifier
        user_id: ID of the user who made the mistake
        type: Type of mistake (grammar, vocabulary, pronunciation, fluency)
        original_text: The original incorrect content
        correction: The corrected version
        explanation: Explanation of why it's a mistake and how to fix it
        context: Original context where the mistake occurred
        situation_context: Additional context for the mistake
        severity: How severe the mistake is (1-5)
        created: When this mistake was first created
        last_practiced: When this mistake was last practiced
        practice_count: Number of times this mistake has been practiced
        success_count: Number of successful practices for this mistake
        frequency: Number of times this mistake has been made
        next_practice_date: When this mistake should be practiced next
        status: Current status of the mistake (NEW, LEARNING, MASTERED)
    """
    def __init__(
        self,
        user_id: ObjectId,
        type: str,  # "grammar", "vocabulary", "pronunciation"
        original_text: str,
        correction: str,
        explanation: str,
        context: str,
        situation_context: Optional[Dict[str, Any]] = None,
        severity: int = 3,  # 1-5, with 5 being most severe
    ):
        self._id = ObjectId()
        self.user_id = user_id
        self.type = type
        self.original_text = original_text
        self.correction = correction
        self.explanation = explanation
        self.context = context
        self.situation_context = situation_context or {}
        self.severity = severity
        self.created = datetime.utcnow()
        self.last_practiced = None
        self.practice_count = 0
        self.success_count = 0
        self.frequency = 1
        self.next_practice_date = datetime.utcnow() + timedelta(days=1)
        self.status = "NEW"  # NEW, LEARNING, MASTERED

    def to_dict(self):
        """Convert the Mistake instance to a dictionary for MongoDB storage."""
        return {
            "_id": self._id,
            "user_id": self.user_id,
            "type": self.type,
            "original_text": self.original_text,
            "correction": self.correction,
            "explanation": self.explanation,
            "context": self.context,
            "situation_context": self.situation_context,
            "severity": self.severity,
            "created": self.created,
            "last_practiced": self.last_practiced,
            "practice_count": self.practice_count,
            "success_count": self.success_count,
            "frequency": self.frequency,
            "next_practice_date": self.next_practice_date,
            "status": self.status
        }
        
    def generate_practice_prompt(self) -> str:
        """Generate a practice prompt for this mistake"""
        if self.type == "grammar":
            return f"Correct the grammar: '{self.original_text}'"
        elif self.type == "vocabulary":
            return f"Suggest a better word or phrase for: '{self.original_text}'"
        else:
            return f"Practice pronouncing: '{self.original_text}'"
            
    def calculate_mastery_level(self) -> float:
        """Calculate the mastery level (0.0-1.0) for this mistake"""
        if self.practice_count == 0:
            return 0.0
        
        # Calculate based on success rate and number of practices
        success_rate = self.success_count / self.practice_count
        practice_factor = min(1.0, self.practice_count / 5.0)  # Max out at 5 practices
        
        return success_rate * practice_factor
