from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from bson import ObjectId

class MessageCreate(BaseModel):
    text: str
    audio_url: Optional[str] = None

class MessageResponse(BaseModel):
    id: str
    conversation_id: str
    role: str
    text: str
    audio_url: Optional[str] = None
    feedback: Optional[dict] = None
    created_at: datetime

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }