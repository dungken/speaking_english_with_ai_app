from enum import Enum

class TranscriptionErrorMessages(Enum):
    DEFAULT_FALLBACK_ERROR = "Your speech could not be transcribed. Please try again or check your microphone."
    EMPTY_TRANSCRIPTION = "It seems like you didn't say anything. Please try again."
    INVALID_TRANSCRIPTION_RESULT = "Invalid transcription result. Please try again."

