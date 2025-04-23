from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from bson import ObjectId

class MessageCreate(BaseModel):
    content: str
    audio_path: Optional[str] = None
    transcription: Optional[str] = None
    feedback_id: Optional[str] = None

class MessageResponse(BaseModel):
    id: str
    conversation_id: str
    sender: str
    content: str
    timestamp: datetime
    audio_path: Optional[str] = None
    transcription: Optional[str] = None
    feedback_id: Optional[str] = None

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }
        
