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
        user_feedback: User-friendly feedback in a free-form text
        timestamp: Timestamp of when the feedback was created
        user_id: ID of the user providing feedback
        transcription: Transcription of the speech being analyzed
    """
    def __init__(
        self,
        target_id: ObjectId,
        target_type: str,  # "message", "audio", etc.
        user_feedback: str,
        user_id: Optional[ObjectId] = None,
        transcription: Optional[str] = None
    ):
        self._id = ObjectId()
        self.target_id = target_id
        self.target_type = target_type
        self.user_feedback = user_feedback
        self.user_id = user_id
        self.transcription = transcription
        self.timestamp = datetime.utcnow()

    def to_dict(self) -> Dict[str, Any]:
        """Convert the Feedback instance to a dictionary for MongoDB storage."""
        return {
            "_id": self._id,
            "target_id": self.target_id,
            "target_type": self.target_type,
            "user_feedback": self.user_feedback,
            "user_id": self.user_id,
            "transcription": self.transcription,
            "timestamp": self.timestamp
        }
 