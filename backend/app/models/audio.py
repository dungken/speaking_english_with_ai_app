from datetime import datetime
from bson import ObjectId

class Audio:
    """
    Model representing an audio recording.
    
    Attributes:
        _id: Unique identifier
        user_id: ID of the user who recorded the audio
        url: URL where the audio file is stored
        duration_seconds: Duration of the audio in seconds
        transcription: Text transcription of the audio content
        language: Language of the audio content
        created_at: Timestamp when the record was created
    """
    def __init__(
        self, 
        user_id: ObjectId, 
        url: str, 
        duration_seconds: float = None,
        transcription: str = None,
        language: str = "en",
    ):
        self._id = ObjectId()
        self.user_id = user_id
        self.url = url
        self.duration_seconds = duration_seconds
        self.transcription = transcription
        self.language = language
        self.created_at = datetime.utcnow()
        self.pronunciation_score = None
        self.pronunciation_feedback = None

    def to_dict(self):
        """Convert the Audio instance to a dictionary for MongoDB storage."""
        return {
            "_id": self._id,
            "user_id": self.user_id,
            "url": self.url,
            "duration_seconds": self.duration_seconds,
            "transcription": self.transcription,
            "language": self.language,
            "created_at": self.created_at,
            "pronunciation_score": self.pronunciation_score,
            "pronunciation_feedback": self.pronunciation_feedback
        }
