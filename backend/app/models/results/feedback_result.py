from datetime import datetime
from typing import Dict, Any, Optional, List, Union


class FeedbackResult:
    """
    Result of feedback generation, as defined in class diagram.
    
    Attributes:
        user_feedback: User-friendly text feedback
        timestamp: Timestamp when feedback was generated
    """
    def __init__(
        self,
        user_feedback: str,
        timestamp: Optional[datetime] = None
    ):
        self.user_feedback = user_feedback
        self.timestamp = timestamp or datetime.utcnow()
   
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for storage"""
        return {
            "user_feedback": self.user_feedback,
            "timestamp": self.timestamp
        } 