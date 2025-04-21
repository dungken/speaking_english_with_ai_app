from datetime import datetime
from bson import ObjectId

class Message:
    def __init__(self, conversation_id: ObjectId, sender: str, content: str, 
                 audio_path: str = None, transcription: str = None, feedback_id: str = None):
        self._id = ObjectId()
        self.conversation_id = conversation_id
        self.sender = sender  # "user" or "ai"
        self.content = content
        self.audio_path = audio_path
        self.transcription = transcription
        self.feedback_id = feedback_id
        self.timestamp = datetime.utcnow()

    def to_dict(self):
        return {
            "_id": self._id,
            "conversation_id": self.conversation_id,
            "sender": self.sender,
            "content": self.content,
            "audio_path": self.audio_path,
            "transcription": self.transcription,
            "feedback_id": self.feedback_id,
            "timestamp": self.timestamp
        }