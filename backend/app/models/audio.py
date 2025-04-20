from datetime import datetime
from bson import ObjectId
from typing import Dict, Any, Optional

class Audio:
    """
    Model representing an audio recording.
    
    Attributes:
        _id: Unique identifier
        user_id: ID of the user who recorded the audio
        url: URL where the audio file is stored (optional)
        filename: Name of the uploaded file (optional)
        file_path: Path to the stored file on server (optional)
        duration_seconds: Duration of the audio in seconds
        transcription: Text transcription of the audio content
        language: Language of the audio content
        pronunciation_score: Overall pronunciation score (0-100)
        pronunciation_feedback: Detailed pronunciation feedback
        language_feedback: Detailed language feedback (grammar, vocabulary, etc.)
        created_at: Timestamp when the record was created
    """
    def __init__(
        self, 
        user_id: ObjectId,
        url: Optional[str] = None,
        filename: Optional[str] = None,
        file_path: Optional[str] = None,
        duration_seconds: Optional[float] = None,
        transcription: Optional[str] = None,
        language: str = "en-US",
        pronunciation_score: Optional[float] = None,
        pronunciation_feedback: Optional[Dict[str, Any]] = None,
        language_feedback: Optional[Dict[str, Any]] = None
    ):
        self._id = ObjectId()
        self.user_id = user_id
        self.url = url
        self.filename = filename
        self.file_path = file_path
        self.duration_seconds = duration_seconds
        self.transcription = transcription
        self.language = language
        self.created_at = datetime.utcnow()
        self.pronunciation_score = pronunciation_score
        self.pronunciation_feedback = pronunciation_feedback
        self.language_feedback = language_feedback

    def to_dict(self):
        """Convert the Audio instance to a dictionary for MongoDB storage."""
        return {
            "_id": self._id,
            "user_id": self.user_id,
            "url": self.url,
            "filename": self.filename,
            "file_path": self.file_path,
            "duration_seconds": self.duration_seconds,
            "transcription": self.transcription,
            "language": self.language,
            "created_at": self.created_at,
            "pronunciation_score": self.pronunciation_score,
            "pronunciation_feedback": self.pronunciation_feedback,
            "language_feedback": self.language_feedback
        }
