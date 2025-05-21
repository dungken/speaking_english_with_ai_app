from datetime import datetime
from bson import ObjectId




class Conversation:
    def __init__(self, user_id: ObjectId, user_role: str, ai_role: str, situation: str,voice_type: str = None):
        self._id = ObjectId()
        self.user_id = user_id
        self.user_role = user_role
        self.ai_role = ai_role  
        self.situation = situation
        self.started_at = datetime.utcnow()
        self.ended_at = None  # Set when the conversation is ended
        self.voice_type = voice_type
    def to_dict(self):
        return {
            "_id": self._id,
            "user_id": self.user_id,
            "user_role": self.user_role,
            "ai_role": self.ai_role,
            "situation": self.situation,
            "started_at": self.started_at,
            "ended_at": self.ended_at,
            "voice_type": self.voice_type
        }
    
    def get_context(self):
        """Returns formatted context for this conversation"""
        return {
            "user_role": self.user_role,
            "ai_role": self.ai_role,
            "situation": self.situation
        }