from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form, Body, Query, BackgroundTasks
from fastapi.responses import JSONResponse
from bson import ObjectId
from typing import List, Optional
import os
import shutil
from pathlib import Path
from datetime import datetime
import base64
import logging

from app.config.database import db
from app.models.audio import Audio
from app.schemas.audio import (
    AudioCreate, 
    AudioResponse, 
    AudioUpload,
    TranscriptionRequest, 
    TranscriptionResponse, 
    PronunciationFeedback,
    AnalysisRequest,
    AnalysisResponse,
    LanguageFeedback,
    FileProcessRequest,
    LocalFileRequest
)
from app.utils.auth import get_current_user
from app.utils.audio_processor import (
    transcribe_audio_local,
    generate_feedback
)
from app.utils.error_handler import get_not_found_exception, handle_general_exception

router = APIRouter()

# Create uploads directory if it doesn't exist
UPLOAD_DIR = Path("app/uploads")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# Define valid audio file extensions
VALID_AUDIO_EXTENSIONS = ['.mp3', '.wav', '.m4a', '.aac', '.ogg', '.flac']

# Set up logger
logger = logging.getLogger(__name__)




@router.post("/analyze-speech", response_model=AnalysisResponse)
async def analyze_speech(
    audio_file: UploadFile = File(...),
    conversation_id: Optional[str] = Form(None),
    current_user: dict = Depends(get_current_user),
    background_tasks: BackgroundTasks = BackgroundTasks()
):
    """
    Analyze speech from an uploaded audio file.
    
    This endpoint follows the sequence in the speech-analysis-sequence diagram:
    1. Transcribe the audio file
    2. Save the audio file to disk
    3. Fetch conversation context if available
    4. Generate dual feedback using Gemini
    5. Store results in database
    6. Trigger background task for mistake extraction
    
    Args:
        audio_file: The audio file to analyze
        conversation_id: Optional ID of the associated conversation
        current_user: Authenticated user information
        background_tasks: FastAPI background tasks manager
        
    Returns:
        Analysis response with transcription and feedback
    """
    try:
        user_id = str(current_user["_id"])
        
        # Initialize services
        from app.utils.speech_service import SpeechService
        from app.utils.feedback_service import FeedbackService
        from app.utils.event_handler import event_handler
        from app.models.results.feedback_result import FeedbackResult
        
        speech_service = SpeechService()
        feedback_service = FeedbackService()
        
        # Step 1: Save the audio file
        file_path, audio_model = speech_service.save_audio_file(audio_file, user_id)
        audio_id = str(audio_model._id)
        
        # Step 2: Transcribe the audio file
        transcription = speech_service.transcribe_audio(Path(file_path))
        
        # Ensure we have a valid transcription to work with
        is_valid_transcription = True
        if not transcription or not transcription.strip():
            logger.warning(f"Empty transcription result for file: {file_path}, using placeholder")
            transcription = "Audio content could not be transcribed. Please try again with a different file format or check audio quality."
            is_valid_transcription = False
        
        # Only update the database if we have a valid transcription
        if is_valid_transcription:
            # Update audio record with transcription
            db.audio.update_one(
                {"_id": ObjectId(audio_id)},
                {"$set": {"transcription": transcription}}
            )
        
        # Step 3: Fetch conversation context if available
        context = {}
        if conversation_id and is_valid_transcription:
            conversation = db.conversations.find_one({"_id": ObjectId(conversation_id)})
            if conversation:
                # Fetch messages to build context
                messages = list(db.messages.find({"conversation_id": ObjectId(conversation_id)})
                              .sort("timestamp", 1)
                              .limit(10))
                
                # Format previous exchanges
                previous_exchanges = []
                for msg in messages:
                    sender = "User" if msg.get("sender") == "user" else "AI"
                    previous_exchanges.append(f"{sender}: {msg.get('content', '')}")
                
                context = {
                    "user_role": conversation.get("user_role", "Student"),
                    "ai_role": conversation.get("ai_role", "Teacher"),
                    "situation": conversation.get("situation", "General conversation"),
                    "previous_exchanges": "\n".join(previous_exchanges)
                }
        
        # Step 4: Generate feedback
        try:
            feedback_result = feedback_service.generate_dual_feedback(transcription, context)
        except Exception as e:
            logger.error(f"Error generating feedback: {str(e)}", exc_info=True)
            # Create a fallback feedback result
            feedback_result = FeedbackResult(
                user_feedback="Unable to generate detailed feedback at this time.",
                detailed_feedback={
                    "grammar_issues": [],
                    "vocabulary_issues": [],
                    "positives": ["Your response was recorded."],
                    "fluency": ["Keep practicing to improve your English skills."]
                }
            )
        
        # Initialize feedback_id as None
        
        feedback_id = None
        
        # Step 5: Store feedback only if we have a valid transcription
        if is_valid_transcription:
            feedback_id = feedback_service.store_feedback(
                user_id, 
                feedback_result, 
                conversation_id,
                transcription=transcription  # Explicitly pass transcription
            )
            
            # If we have a conversation ID, add a message with this transcription
            if conversation_id:
                from app.utils.conversation_service import ConversationService
                conversation_service = ConversationService()
                
                # Add user message to conversation
                message = conversation_service.add_message(
                    conversation_id,
                    {
                        "sender": "user",
                        "content": transcription,
                        "audio_path": str(file_path),
                        "transcription": transcription,
                        "generate_response": False  # Don't auto-generate an AI response yet
                    }
                )
                
                # Link feedback to message
                if message and feedback_id:
                    db.messages.update_one(
                        {"_id": ObjectId(message["_id"])},
                        {"$set": {"feedback_id": feedback_id}}
                    )
            
            # Step 6: Trigger background task for mistake extraction
            if feedback_id:
                background_tasks.add_task(
                    event_handler.on_new_feedback,
                    feedback_id,
                    user_id,  # Explicitly pass user_id to background task
                    transcription  # Explicitly pass transcription to background task
                )
        
        # Step 7: Prepare response
        return AnalysisResponse(
            transcription=transcription,
            user_feedback=feedback_result.user_feedback,
            detailed_feedback=feedback_result.detailed_feedback.to_dict() if hasattr(feedback_result, 'detailed_feedback') else {},
            audio_id=audio_id,
            feedback_id=feedback_id
        )
        
    except Exception as e:
        logger.error(f"Error analyzing speech: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to analyze speech: {str(e)}"
        )

async def save_audio_file(file: UploadFile, user_id: str) -> str:
    """
    Save an uploaded audio file to the server.
    
    Args:
        file: The audio file to save
        user_id: ID of the user
        
    Returns:
        Path to the saved file
    """
    # Create user directory if it doesn't exist
    user_dir = UPLOAD_DIR / str(user_id)
    user_dir.mkdir(exist_ok=True)
    
    # Generate unique filename
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    safe_filename = f"{timestamp}_{file.filename.replace(' ', '_')}"
    file_path = user_dir / safe_filename
    
    # Save the file
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    return str(file_path)
