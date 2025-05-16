import logging
import os
import shutil
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, Optional, Tuple
from fastapi import UploadFile, HTTPException, status
from bson import ObjectId
import inspect
from transcription_error_message import TranscriptionErrorMessages
from app.config.database import db
from app.models.audio import Audio
from app.utils.audio_processor import transcribe_audio_local,transcribe_audio_with_whisper

# Set up logger
logger = logging.getLogger(__name__)

# Create uploads directory if it doesn't exist
UPLOAD_DIR = Path("app/uploads")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

class SpeechService:
    """
    Service for handling speech-related operations.
    
    This service provides functionality to:
    1. Transcribe audio content to text
    2. Save audio files to disk with proper organization
    """
    FALLBACK_TRANSCRIPTION_ERROR_MESSAGE = "Your speech could not be transcribed. Please try again or check your microphone"
    
    def transcribe_from_upload(self, audio_file: UploadFile, language_code: str = "en-US") -> Tuple[str, Path]:
        """
        Create a temporary file from upload and transcribe it without storing in DB first.
        
        This optimized method creates a temporary file, transcribes it, and returns the
        transcription without adding it to the database until we know transcription was successful.
        
        Args:
            audio_file: The audio file from the upload
            language_code: Language code for transcription (default: en-US)
            
        Returns:
            A tuple containing (transcription text, temporary file path)
            
        Raises:
            TranscriptionError: If transcription fails
        """
        try:
            import tempfile
            import os
            
            # Create a temporary file with the same extension as the uploaded file
            _, ext = os.path.splitext(audio_file.filename)
            with tempfile.NamedTemporaryFile(delete=False, suffix=ext) as tmp_file:
                # Copy uploaded file to temporary file
                shutil.copyfileobj(audio_file.file, tmp_file)
                tmp_path = Path(tmp_file.name)
            
            # Make sure we reset the file pointer for potential future use
            audio_file.file.seek(0)
            
            # Transcribe the temporary file
            transcription = self.transcribe_audio(tmp_path, language_code)
            
            # Return both the transcription and the path to the temporary file
            return transcription, tmp_path
            
        except Exception as e:
            logger.error(f"Error transcribing from upload: {str(e)}")
            # Return the error message and None for the file path
            return self._try_fallback_transcription(Path(""), language_code), None
    
    def transcribe_audio(self, audio_file: Path, language_code: str = "en-US", use_whisper: bool = True) -> str:
        """
        Transcribe audio to text using the appropriate service.
        
        Args:
            audio_file: Path to the audio file to transcribe
            language_code: Language code for transcription (default: en-US)
            
        Returns:
            Transcription text
            
        Raises:
            TranscriptionError: If transcription fails
        """
        try:
            transcription_text = ""
            if not use_whisper:
                # Use local transcription service - returns a dictionary with 'text' and 'confidence'
                transcription_text = transcribe_audio_local(audio_file, language_code)
            else:
                transcription_text = transcribe_audio_with_whisper(audio_file, language_code)
                
            return transcription_text if transcription_text else TranscriptionErrorMessages.EMPTY_TRANSCRIPTION.value
            
        except Exception as e:
            logger.error(f"Error in local transcription: {str(e)}")
            return self._try_fallback_transcription(audio_file, language_code)
    
    
        
        
    def _try_fallback_transcription(self, audio_file: Path, language_code: str = "en-US") -> str:
        """
        Attempt to transcribe using alternative methods when the primary method fails.
        
        Args:
            audio_file: Path to the audio file to transcribe
            language_code: Language code for transcription (default: en-US)
            
        Returns:
            Transcription text or a default message if all methods fail
        """
        try:
            # Try to use an external API service like Google Cloud Speech-to-Text
            # This requires proper configuration in the environment
            from google.cloud import speech
            
            client = speech.SpeechClient()
            
            with open(audio_file, "rb") as audio_file_content:
                content = audio_file_content.read()
            
            audio = speech.RecognitionAudio(content=content)
            config = speech.RecognitionConfig(
                encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
                sample_rate_hertz=16000,
                language_code=language_code,
            )
            
            response = client.recognize(config=config, audio=audio)
            transcription = " ".join([result.alternatives[0].transcript for result in response.results])
            
            if transcription and transcription.strip():
                return transcription
        except Exception as e:
            logger.warning(f"Fallback transcription failed: {str(e)}")
        
        # If all else fails, return a default message
        # This prevents downstream processes from failing due to missing transcription
        return TranscriptionErrorMessages.FALLBACK_ERROR.value
    
    def save_audio_file(self, audio_file: UploadFile, user_id: str) -> Tuple[str, Audio]:
        """
        Save an audio file to disk and create a database record.
        
        Args:
            audio_file: The audio file to save
            user_id: ID of the user who owns the file
            
        Returns:
            Tuple containing the file path and Audio model
            
        Raises:
            StorageError: If file saving fails
        """
        try:
            # Convert string user_id to ObjectId
            user_object_id = ObjectId(user_id)
            
            # Create user directory if it doesn't exist
            user_dir = UPLOAD_DIR / str(user_id)
            user_dir.mkdir(exist_ok=True)
            
            # Generate unique filename
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            safe_filename = f"{timestamp}_{audio_file.filename.replace(' ', '_')}"
            file_path = user_dir / safe_filename
            
            # Save the file
            with open(file_path, "wb") as buffer:
                shutil.copyfileobj(audio_file.file, buffer)
            
            # Create audio record
            new_audio = Audio(
                user_id=user_object_id,
                filename=audio_file.filename,
                file_path=str(file_path),
                language="en-US"  # Default language
            )
            
            # Insert into database
            result = db.audio.insert_one(new_audio.to_dict())
            
            # Fetch the inserted audio
            created_audio = db.audio.find_one({"_id": result.inserted_id})
            
            # Store the _id value
            audio_id = created_audio["_id"]
            
            # Get the arguments that Audio.__init__ accepts
            audio_init_params = inspect.signature(Audio.__init__).parameters
            
            # Filter created_audio to only include fields accepted by Audio constructor
            filtered_audio_data = {}
            for key, value in created_audio.items():
                # Skip _id and created_at, which are automatically set in the constructor
                if key in audio_init_params and key not in ["_id", "created_at"]:
                    filtered_audio_data[key] = value
            
            # Create Audio object from the filtered data
            audio_model = Audio(**filtered_audio_data)
            
            # Add the id manually to the audio model
            audio_model._id = audio_id
            
            # Return the file path and Audio model
            return str(file_path), audio_model
            
        except Exception as e:
            logger.error(f"Error saving audio file: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to save audio file: {str(e)}"
            )