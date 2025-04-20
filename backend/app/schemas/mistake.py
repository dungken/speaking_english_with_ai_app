from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from bson import ObjectId
from enum import Enum

class MistakeType(str, Enum):
    """Enum for types of language mistakes."""
    GRAMMAR = "grammar"
    VOCABULARY = "vocabulary"
    PRONUNCIATION = "pronunciation"
    FLUENCY = "fluency"
    CULTURAL_CONTEXT = "cultural_context"

class MistakeBase(BaseModel):
    """Base schema for mistake data."""
    type: MistakeType = Field(..., description="Type of mistake")
    original_content: str = Field(..., description="The original incorrect content")
    correction: str = Field(..., description="The corrected version")
    explanation: str = Field(..., description="Explanation of why it's a mistake and how to fix it")
    context: str = Field(..., description="Original context where the mistake occurred")
    severity: int = Field(3, description="How severe the mistake is (1-5, with 5 being most severe)")

class MistakeCreate(MistakeBase):
    """Schema for creating a new mistake record."""
    pass

class MistakeResponse(MistakeBase):
    """Schema for mistake response."""
    id: str = Field(..., alias="_id", description="Unique identifier for the mistake")
    user_id: str = Field(..., description="ID of the user who made the mistake")
    frequency: int = Field(..., description="Number of times this mistake has been made")
    last_occurred: datetime = Field(..., description="When this mistake was last made")
    in_drill_queue: bool = Field(..., description="Whether this mistake is queued for drilling")
    next_practice_date: datetime = Field(..., description="When this mistake should be practiced next")
    created_at: datetime = Field(..., description="When this mistake was first recorded")
    updated_at: datetime = Field(..., description="When this mistake was last updated")
    is_learned: bool = Field(..., description="Whether this mistake has been learned")
    successful_practices: int = Field(..., description="Number of successful practice attempts")
    failed_practices: int = Field(..., description="Number of failed practice attempts")
    
    class Config:
        """Configuration for Pydantic model."""
        from_attributes = True
        populate_by_name = True
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }

class MistakePracticeResult(BaseModel):
    """Schema for reporting practice results."""
    mistake_id: str = Field(..., description="ID of the mistake being practiced")
    user_text: str = Field(..., description="Text provided by the user in practice")
    performance_score: float = Field(..., description="Score from 0-1 indicating practice performance")
    is_successful: bool = Field(..., description="Whether the practice attempt was successful")

class MistakeDrillSession(BaseModel):
    """Schema for a mistake drilling session."""
    mistakes: List[MistakeResponse] = Field(..., description="List of mistakes to practice")
    session_id: str = Field(..., description="Unique identifier for this drill session")
    created_at: datetime = Field(..., description="When this session was created")

class MistakeUpdate(BaseModel):
    """Schema for updating mistake properties."""
    severity: Optional[int] = Field(None, description="Updated severity (1-5)")
    is_learned: Optional[bool] = Field(None, description="Mark as learned")
    in_drill_queue: Optional[bool] = Field(None, description="Include in drill queue")
