from pydantic import BaseModel, Field, HttpUrl
from typing import Optional, List, Dict, Any
from datetime import datetime
from bson import ObjectId

class AudioBase(BaseModel):
    """Base schema with common audio properties."""
    url: Optional[HttpUrl] = Field(None, description="URL where the audio file is stored")
    duration_seconds: Optional[float] = Field(None, description="Duration of the audio in seconds")
    language: str = Field("en-US", description="Language code of the audio content")

class AudioCreate(AudioBase):
    """Schema for creating a new audio record."""
    pass

class AudioUpload(BaseModel):
    """Schema for file upload metadata."""
    filename: str = Field(..., description="Name of the uploaded file")
    duration_seconds: Optional[float] = Field(None, description="Duration of the audio in seconds")
    language: str = Field("en-US", description="Language code of the audio content")

class AudioResponse(BaseModel):
    """Schema for audio response including transcription and pronunciation data."""
    id: str = Field(..., alias="_id", description="Unique identifier for the audio record")
    user_id: str = Field(..., description="ID of the user who created the audio")
    url: Optional[str] = Field(None, description="URL where the audio file is stored")
    filename: Optional[str] = Field(None, description="Name of the uploaded file")
    duration_seconds: Optional[float] = Field(None, description="Duration of the audio in seconds")
    language: str = Field("en-US", description="Language code of the audio content")
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

class FileProcessRequest(BaseModel):
    """Schema for requesting processing of an uploaded file."""
    file_id: str = Field(..., description="ID of the uploaded file to process")
    language: str = Field("en-US", description="Language code for processing")
    reference_text: Optional[str] = Field(None, description="Optional reference text for comparison")

class TranscriptionRequest(BaseModel):
    """Schema for requesting audio transcription."""
    audio_url: Optional[HttpUrl] = Field(None, description="URL of the audio to transcribe")
    file_id: Optional[str] = Field(None, description="ID of the uploaded file to transcribe")
    language: str = Field("en-US", description="Language code for transcription")

class LocalFileRequest(BaseModel):
    """Schema for requesting audio processing from a local file path."""
    file_path: str = Field(..., description="Absolute path to the audio file on the server. Must be a path accessible to the server process.")
    language: str = Field("en-US", description="Language code for processing")
    reference_text: Optional[str] = Field(None, description="Optional reference text for comparison")
    user_id: Optional[str] = Field(None, description="Optional user ID to associate with the recording")

class TranscriptionResponse(BaseModel):
    """Schema for transcription response."""
    text: str = Field(..., description="Transcribed text")
    confidence: Optional[float] = Field(None, description="Confidence score for the transcription")
    
class PronunciationFeedback(BaseModel):
    """Schema for pronunciation feedback."""
    overall_score: float = Field(..., description="Overall pronunciation score (0-100)")
    word_scores: Dict[str, float] = Field({}, description="Per-word pronunciation scores")
    improvement_suggestions: List[str] = Field([], description="Suggestions for pronunciation improvement")
    
class GrammarIssue(BaseModel):
    """Schema for grammar error."""
    issue: str = Field(..., description="Description of the grammar issue")
    correction: str = Field(..., description="Suggested correction")
    explanation: Optional[str] = Field(None, description="Explanation of the grammar rule")

class VocabularyIssue(BaseModel):
    """Schema for vocabulary suggestions."""
    original: str = Field(..., description="Original word or phrase used")
    suggestion: str = Field(..., description="Better alternative")
    context: Optional[str] = Field(None, description="Why this is better in this context")

class LanguageFeedback(BaseModel):
    """Schema for comprehensive language feedback."""
    grammar: List[GrammarIssue] = Field([], description="Grammar issues and corrections")
    vocabulary: List[VocabularyIssue] = Field([], description="Vocabulary improvement suggestions")
    fluency: List[str] = Field([], description="Suggestions for improving natural flow")
    positives: List[str] = Field([], description="Positive aspects of the response")

class AnalysisRequest(BaseModel):
    """Schema for requesting comprehensive spoken English analysis."""
    audio_url: Optional[HttpUrl] = Field(None, description="URL of the audio to analyze")
    file_id: Optional[str] = Field(None, description="ID of the uploaded file to analyze")
    reference_text: Optional[str] = Field(None, description="Optional reference text for comparison")
    language: str = Field("en-US", description="Language code for analysis")

class AnalysisResponse(BaseModel):
    """Schema for comprehensive analysis response."""
    audio_id: Optional[str] = Field(None, description="ID of the analyzed audio")
    transcription: str = Field(..., description="Transcribed text from the audio")
    user_feedback: str = Field(..., description="User-friendly feedback text")
    grammar_issues: List[Dict[str, Any]] = Field([], description="Grammar issues identified")
    vocabulary_issues: List[Dict[str, Any]] = Field([], description="Vocabulary improvement suggestions")
    conversation_id: Optional[str] = Field(None, description="ID of the conversation if applicable")
    
    class Config:
        """Configuration for Pydantic model."""
        from_attributes = True
        json_schema_extra = {
            "example": {
                "transcription": "I am excited to improve my English speaking skills.",
                "confidence": 0.92,
                "pronunciation": {
                    "overall_score": 85.5,
                    "word_scores": {
                        "excited": 75.0,
                        "improve": 88.0
                    },
                    "improvement_suggestions": [
                        "Practice the 'x' sound in 'excited'",
                        "Work on the stress pattern in longer words"
                    ]
                },
                "language_feedback": {
                    "grammar": [],
                    "vocabulary": [
                        {
                            "original": "excited",
                            "suggestion": "enthusiastic",
                            "context": "More formal alternative with similar meaning"
                        }
                    ],
                    "fluency": [
                        "Try using more complex sentence structures"
                    ],
                    "positives": [
                        "Good use of the first person",
                        "Clear expression of motivation"
                    ]
                }
            }
        }
