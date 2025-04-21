from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
from enum import Enum
from datetime import datetime
from bson import ObjectId

class MistakeType(str, Enum):
    """Enum for mistake types."""
    GRAMMAR = "grammar"
    VOCABULARY = "vocabulary"
    PRONUNCIATION = "pronunciation"

class MistakeStatus(str, Enum):
    """Enum for mistake status."""
    NEW = "NEW"
    LEARNING = "LEARNING"
    MASTERED = "MASTERED"

class MistakeBase(BaseModel):
    """Base schema for mistakes."""
    type: MistakeType = Field(..., description="Type of mistake")
    original_text: str = Field(..., description="Original text containing the mistake")
    correction: str = Field(..., description="Corrected version")
    explanation: str = Field(..., description="Explanation of the mistake")
    context: str = Field(..., description="Context where the mistake occurred")
    situation_context: Dict[str, Any] = Field(default_factory=dict, description="Additional context data")
    severity: int = Field(..., ge=1, le=5, description="Severity of the mistake (1-5)")

class MistakeCreate(MistakeBase):
    """Schema for creating a mistake."""
    user_id: str = Field(..., description="ID of the user who made the mistake")

class MistakeResponse(MistakeBase):
    """Schema for mistake response."""
    id: str = Field(..., description="Unique identifier for the mistake")
    user_id: str = Field(..., description="ID of the user who made the mistake")
    created: datetime = Field(..., description="When this mistake was first recorded")
    last_practiced: Optional[datetime] = Field(None, description="When this mistake was last practiced")
    practice_count: int = Field(0, description="Number of times this mistake has been practiced")
    success_count: int = Field(0, description="Number of successful practices")
    frequency: int = Field(1, description="Number of times this mistake has been made")
    next_practice_date: datetime = Field(..., description="When this mistake should be practiced next")
    status: MistakeStatus = Field(..., description="Current status of the mistake")

    class Config:
        """Configuration for Pydantic model."""
        use_enum_values = True
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }

class MistakePracticeResult(BaseModel):
    """Schema for recording practice results."""
    mistake_id: str = Field(..., description="ID of the mistake that was practiced")
    user_answer: str = Field(..., description="User's answer during practice")
    was_successful: bool = Field(..., description="Whether the practice was successful")
    feedback: str = Field(..., description="Feedback on the practice attempt")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="When this practice occurred")

class PracticeSession(BaseModel):
    """Schema for a practice session."""
    id: str = Field(..., description="Unique identifier for the session")
    user_id: str = Field(..., description="ID of the user")
    started_at: datetime = Field(..., description="When this session was created")
    completed_at: Optional[datetime] = Field(None, description="When this session was completed")
    mistakes_practiced: List[MistakePracticeResult] = Field(..., description="Results of mistakes practiced")

    class Config:
        """Configuration for Pydantic model."""
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }
        
    def calculate_success(self) -> float:
        """Calculate the success rate for this practice session."""
        if not self.mistakes_practiced:
            return 0.0
        
        success_count = sum(1 for result in self.mistakes_practiced if result.was_successful)
        return success_count / len(self.mistakes_practiced)

class MistakeDrillSession(BaseModel):
    """Schema for a mistake drilling session."""
    mistakes: List[MistakeResponse] = Field(..., description="List of mistakes to practice")
    session_id: str = Field(..., description="Unique identifier for this drill session")
    created_at: datetime = Field(..., description="When this session was created")

class MistakeUpdate(BaseModel):
    """Schema for updating mistake properties."""
    severity: Optional[int] = Field(None, description="Updated severity (1-5)")
    status: Optional[MistakeStatus] = Field(None, description="Updated status")
    in_drill_queue: Optional[bool] = Field(None, description="Include in drill queue")

class PracticeItemResponse(BaseModel):
    """Schema for a practice item response"""
    mistake_id: str = Field(..., description="ID of the mistake")
    type: str = Field(..., description="Type of mistake (GRAMMAR or VOCABULARY)")
    practice_prompt: str = Field(..., description="Generated prompt for practice")
    original_text: str = Field(..., description="Original text with the mistake")
    context: str = Field(..., description="Context with highlighted mistake")
    correction: str = Field(..., description="Correct version")
    explanation: str = Field(..., description="Explanation of the mistake")
    example_usage: Optional[str] = Field(None, description="Example usage (for vocabulary)")

class PracticeResultRequest(BaseModel):
    """Schema for submitting practice result"""
    was_successful: bool = Field(..., description="Whether the practice was successful")
    user_answer: str = Field(..., description="User's answer during practice")

class PracticeResultResponse(BaseModel):
    """Schema for practice result response"""
    mistake_id: str = Field(..., description="ID of the mistake")
    mastery_level: int = Field(..., ge=0, le=10, description="Current mastery level (0-10)")
    next_practice_date: datetime = Field(..., description="Next scheduled practice date")
    status: str = Field(..., description="Current status (NEW, LEARNING, or MASTERED)")
    feedback: str = Field(..., description="Feedback on the practice attempt")

class MistakeStatistics(BaseModel):
    """Schema for mistake statistics"""
    total_count: int = Field(..., description="Total number of mistakes")
    mastered_count: int = Field(..., description="Number of mastered mistakes")
    learning_count: int = Field(..., description="Number of mistakes in learning")
    new_count: int = Field(..., description="Number of new mistakes")
    grammar_count: int = Field(..., description="Number of grammar mistakes")
    vocabulary_count: int = Field(..., description="Number of vocabulary mistakes")
    due_for_practice: int = Field(..., description="Number of mistakes due for practice")
    mastery_percentage: float = Field(..., description="Percentage of mastered mistakes")
