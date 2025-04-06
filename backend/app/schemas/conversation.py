from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from bson import ObjectId

class ConversationCreate(BaseModel):
    user_role: str
    ai_role: str
    situation: str

class ConversationResponse(BaseModel):
    id: str
    user_id: str
    ai_assistant: str
    situation_description: str
    created_at: datetime
    score: Optional[float] = None

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }
