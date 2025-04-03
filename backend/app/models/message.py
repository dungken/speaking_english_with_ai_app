from datetime import datetime
from bson import ObjectId

class Message:
    def __init__(self, conversation_id: ObjectId, role: str, text: str, audio_url: str = None):
        self._id = ObjectId()
        self.conversation_id = conversation_id
        self.role = role  # "user" or "ai"
        self.text = text
        self.audio_url = audio_url
        self.feedback = None  # Add later if implementing feedback
        self.created_at = datetime.utcnow()

    def to_dict(self):
        return {
            "_id": self._id,
            "conversation_id": self.conversation_id,
            "role": self.role,
            "text": self.text,
            "audio_url": self.audio_url,
            "feedback": self.feedback,
            "created_at": self.created_at
        }