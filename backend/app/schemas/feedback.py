from pydantic import BaseModel, Field, HttpUrl
from typing import List, Dict, Any, Optional
from datetime import datetime
from bson import ObjectId

class GrammarIssue(BaseModel):
    """Schema for a grammar issue."""
    issue: str = Field(..., description="The exact problematic text")
    correction: str = Field(..., description="How it should be corrected")
    explanation: str = Field(..., description="Why this is an issue")
    severity: int = Field(..., ge=1, le=5, description="Severity level (1-5)")

class VocabularyIssue(BaseModel):
    """Schema for a vocabulary issue."""
    original: str = Field(..., description="The word or phrase used")
    better_alternative: str = Field(..., description="A better word or phrase")
    reason: str = Field(..., description="Why the alternative is better")
    example_usage: str = Field(..., description="Example sentence using the better alternative")

class VocabularySuggestion(BaseModel):
    """Schema for a vocabulary suggestion."""
    original: str = Field(..., description="Original word or phrase used")
    suggestion: str = Field(..., description="Better alternative")
    context: str = Field(..., description="Why this is better in this context")

class PronunciationDetail(BaseModel):
    """Schema for pronunciation details."""
    overall_score: float = Field(..., description="Overall pronunciation score (0-100)")
    word_scores: Dict[str, float] = Field({}, description="Per-word pronunciation scores")
    improvement_suggestions: List[str] = Field([], description="Suggestions for pronunciation improvement")

class FeedbackBase(BaseModel):
    """Base schema for feedback."""
    grammar_issues: List[GrammarIssue] = Field([], description="Grammar issues detected")
    vocabulary_suggestions: List[VocabularySuggestion] = Field([], description="Vocabulary improvement suggestions")
    pronunciation_feedback: Optional[PronunciationDetail] = Field(None, description="Pronunciation feedback if applicable")
    fluency_score: Optional[float] = Field(None, description="Score for fluency/natural expression (0-100)")
    positive_aspects: List[str] = Field([], description="Positive aspects in the user's performance")
    prioritized_improvements: List[str] = Field([], description="Most important improvements to focus on")

class FeedbackResult(BaseModel):
    """Schema for feedback result"""
    user_feedback: str = Field(..., description="User-friendly feedback text")
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }

class FeedbackCreate(BaseModel):
    """Schema for creating feedback."""
    target_id: str = Field(..., description="ID of the entity receiving feedback")
    target_type: str = Field(..., description="Type of entity receiving feedback")
    user_feedback: str = Field(..., description="User-friendly feedback text")

class FeedbackResponse(BaseModel):
    """Schema for feedback response."""
    id: str = Field(..., alias="_id", description="Unique identifier for the feedback")
    target_id: str = Field(..., description="ID of the entity receiving feedback") 
    target_type: str = Field(..., description="Type of entity receiving feedback")
    user_feedback: str = Field(..., description="User-friendly feedback text")
    timestamp: datetime = Field(..., description="Timestamp when the feedback was created")
    
    class Config:
        """Configuration for Pydantic model."""
        from_attributes = True
        populate_by_name = True
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }

class FeedbackRequest(BaseModel):
    """Schema for requesting feedback generation."""
    text: str = Field(..., description="User text to analyze")
    reference_text: Optional[str] = Field(None, description="Reference text to compare against")
    audio_path: Optional[str] = Field(None, description="Path to audio recording if available")
