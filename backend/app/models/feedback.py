from datetime import datetime
from bson import ObjectId
from typing import Dict, List, Any, Optional

class Feedback:
    """
    Model representing feedback for a user's language performance.
    
    Attributes:
        _id: Unique identifier
        target_id: ID of the entity receiving feedback (message, audio, etc.)
        target_type: Type of entity receiving feedback ("message", "audio", etc.)
        user_feedback: User's feedback in a free-form text
        detailed_feedback: Detailed feedback in a structured format
        timestamp: Timestamp of when the feedback was created
    """
    def __init__(
        self,
        target_id: ObjectId,
        target_type: str,  # "message", "audio", etc.
        user_feedback: str,
        grammar_issues: Optional[List[Dict[str, Any]]] = None,
        vocabulary_issues: Optional[List[Dict[str, Any]]] = None,
    ):
        self._id = ObjectId()
        self.target_id = target_id
        self.target_type = target_type
        self.user_feedback = user_feedback
        self.detailed_feedback = {
            "grammar_issues": grammar_issues or [],
            "vocabulary_issues": vocabulary_issues or []
        }
        self.timestamp = datetime.utcnow()

    def to_dict(self):
        """Convert the Feedback instance to a dictionary for MongoDB storage."""
        return {
            "_id": self._id,
            "target_id": self.target_id,
            "target_type": self.target_type,
            "user_feedback": self.user_feedback,
            "detailed_feedback": self.detailed_feedback,
            "timestamp": self.timestamp
        }
        
    def generate_user_friendly_text(self):
        """Generate user-friendly text from detailed feedback"""
        return self.user_feedback
        
    def export_to_mistakes(self) -> List[Dict[str, Any]]:
        """
        Export feedback to mistake format for mistake tracking.
        
        Returns:
            List of mistakes for tracking and drilling
        """
        mistakes = []
        
        # Convert grammar issues to mistakes
        for issue in self.detailed_feedback["grammar_issues"]:
            mistakes.append({
                "type": "grammar",
                "original_text": issue.get("issue", ""),
                "correction": issue.get("correction", ""),
                "explanation": issue.get("explanation", ""),
                "context": "Grammar issue from feedback",
                "severity": issue.get("severity", 3)
            })
            
        # Convert vocabulary issues to mistakes
        for issue in self.detailed_feedback["vocabulary_issues"]:
            mistakes.append({
                "type": "vocabulary",
                "original_text": issue.get("original", ""),
                "correction": issue.get("better_alternative", ""),
                "explanation": issue.get("reason", ""),
                "context": issue.get("example_usage", ""),
                "severity": 3
            })
                    
        return mistakes
