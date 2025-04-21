from backend.app.routes.audio import router as speech_controller
from backend.app.routes.user import router as user_controller
from backend.app.routes.conversation import router as conversation_controller
from backend.app.routes.mistake import router as mistake_controller

__all__ = [
    'speech_controller',
    'user_controller',
    'conversation_controller',
    'mistake_controller'
]
