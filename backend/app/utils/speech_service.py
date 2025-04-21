import logging
import os
import shutil
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, Optional, Tuple
from fastapi import UploadFile, HTTPException, status
from bson import ObjectId

from app.config.database import db
from app.models.audio import Audio
from app.utils.audio_processor import transcribe_audio_local

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
    
    def transcribe_audio(self, audio_file: Path, language_code: str = "en-US") -> str:
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
            # Use local transcription service
            transcription = transcribe_audio_local(str(audio_file), language_code)
            
            # Check if transcription is empty
            if not transcription or not transcription.strip():
                logger.warning(f"Empty transcription for file: {audio_file}")
                return ""
                
            return transcription
        except Exception as e:
            logger.error(f"Transcription error: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to transcribe audio: {str(e)}"
            )
    
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
            
            # Return the file path and Audio model
            return str(file_path), Audio(**created_audio)
            
        except Exception as e:
            logger.error(f"Error saving audio file: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to save audio file: {str(e)}"
            ) 