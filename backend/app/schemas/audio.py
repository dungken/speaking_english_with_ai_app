from pydantic import BaseModel, Field, HttpUrl
from typing import Optional, List, Dict, Any
from datetime import datetime
from bson import ObjectId

class AudioBase(BaseModel):
    """Base schema with common audio properties."""
    url: HttpUrl = Field(..., description="URL where the audio file is stored")
    duration_seconds: Optional[float] = Field(None, description="Duration of the audio in seconds")
    language: str = Field("en", description="Language code of the audio content")

class AudioCreate(AudioBase):
    """Schema for creating a new audio record."""
    pass

class AudioResponse(AudioBase):
    """Schema for audio response including transcription and pronunciation data."""
    id: str = Field(..., alias="_id", description="Unique identifier for the audio record")
    user_id: str = Field(..., description="ID of the user who created the audio")
    transcription: Optional[str] = Field(None, description="Text transcription of the audio content")
    pronunciation_score: Optional[float] = Field(None, description="Overall pronunciation score (0-100)")
    pronunciation_feedback: Optional[Dict[str, Any]] = Field(None, description="Detailed pronunciation feedback")
    created_at: datetime = Field(..., description="Timestamp when the audio was recorded")
    
    class Config:
        """Configuration for Pydantic model."""
        from_attributes = True
        populate_by_name = True
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }

class TranscriptionRequest(BaseModel):
    """Schema for requesting audio transcription."""
    audio_url: HttpUrl = Field(..., description="URL of the audio to transcribe")
    language: str = Field("en", description="Language code for transcription")

class TranscriptionResponse(BaseModel):
    """Schema for transcription response."""
    text: str = Field(..., description="Transcribed text")
    confidence: Optional[float] = Field(None, description="Confidence score for the transcription")
    
class PronunciationFeedback(BaseModel):
    """Schema for pronunciation feedback."""
    overall_score: float = Field(..., description="Overall pronunciation score (0-100)")
    word_scores: Dict[str, float] = Field({}, description="Per-word pronunciation scores")
    improvement_suggestions: List[str] = Field([], description="Suggestions for pronunciation improvement")
    phonetic_errors: Optional[List[Dict[str, Any]]] = Field(None, description="Detailed phonetic errors")
