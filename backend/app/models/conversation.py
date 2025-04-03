from datetime import datetime
from bson import ObjectId

class Conversation:
    def __init__(self, user_id: ObjectId, user_role: str, ai_role: str, situation: str):
        self._id = ObjectId()
        self.user_id = user_id
        self.topic = f"{user_role} and {ai_role} in {situation}"
        self.ai_assistant = ai_role
        self.situation_description = situation
        self.created_at = datetime.utcnow()
        self.score = None  # Updated later if you add scoring

    def to_dict(self):
        return {
            "_id": self._id,
            "user_id": self.user_id,
            "topic": self.topic,
            "ai_assistant": self.ai_assistant,
            "situation_description": self.situation_description,
            "created_at": self.created_at,
            "score": self.score
        }