from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from bson import ObjectId

class ConversationCreate(BaseModel):
    user_role: str
    ai_role: str
    situation: str
    

class ConversationResponse(BaseModel):
    id: str
    user_id: str
    user_role: str
    ai_role: str
    situation: str
    started_at: datetime
    ended_at: Optional[datetime] = None

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }
