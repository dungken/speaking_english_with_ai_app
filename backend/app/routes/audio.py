from fastapi import APIRouter, Depends, HTTPException, status
from bson import ObjectId
from typing import List, Optional

from app.config.database import db
from app.models.audio import Audio
from app.schemas.audio import AudioCreate, AudioResponse, TranscriptionRequest, TranscriptionResponse, PronunciationFeedback
from app.utils.auth import get_current_user
from app.utils.audio_processor import transcribe_audio, assess_pronunciation
from app.utils.error_handler import get_not_found_exception, handle_general_exception

router = APIRouter()

@router.post("/upload", response_model=AudioResponse)
async def upload_audio(
    audio: AudioCreate,
    current_user: dict = Depends(get_current_user)
):
    """
    Register a new audio recording in the system.
    
    Args:
        audio: Audio metadata including URL
        current_user: Authenticated user information
        
    Returns:
        The created audio record
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Create audio record
        new_audio = Audio(
            user_id=user_id,
            url=str(audio.url),
            duration_seconds=audio.duration_seconds,
            language=audio.language
        )
        
        # Insert into database
        result = db.audio.insert_one(new_audio.to_dict())
        
        # Fetch the inserted audio
        created_audio = db.audio.find_one({"_id": result.inserted_id})
        
        # Convert ObjectId to string
        created_audio["_id"] = str(created_audio["_id"])
        created_audio["user_id"] = str(created_audio["user_id"])
        
        return AudioResponse(**created_audio)
    
    except Exception as e:
        raise handle_general_exception(e, "audio")


@router.post("/transcribe", response_model=TranscriptionResponse)
async def transcribe(
    request: TranscriptionRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Transcribe audio content to text.
    
    Args:
        request: Transcription request with audio URL
        current_user: Authenticated user information
        
    Returns:
        The transcription result
    """
    try:
        # Call transcription service
        result = transcribe_audio(
            audio_url=str(request.audio_url),
            language_code=request.language
        )
        
        # Update audio record if it exists
        audio_record = db.audio.find_one({"url": str(request.audio_url)})
        if audio_record:
            db.audio.update_one(
                {"_id": audio_record["_id"]},
                {"$set": {"transcription": result["text"]}}
            )
        
        return TranscriptionResponse(
            text=result["text"],
            confidence=result.get("confidence")
        )
    
    except Exception as e:
        raise handle_general_exception(e, "audio transcription")


@router.post("/pronunciation", response_model=PronunciationFeedback)
async def analyze_pronunciation(
    request: TranscriptionRequest,
    reference_text: Optional[str] = None,
    current_user: dict = Depends(get_current_user)
):
    """
    Analyze pronunciation quality of an audio recording.
    
    Args:
        request: Audio URL to analyze
        reference_text: Optional reference text to compare against
        current_user: Authenticated user information
        
    Returns:
        Pronunciation assessment and feedback
    """
    try:
        # First transcribe if not already done
        transcription_result = transcribe_audio(
            audio_url=str(request.audio_url),
            language_code=request.language
        )
        
        # Get pronunciation assessment
        assessment = assess_pronunciation(
            audio_url=str(request.audio_url),
            transcription=transcription_result["text"],
            reference_text=reference_text
        )
        
        # Update audio record if it exists
        audio_record = db.audio.find_one({"url": str(request.audio_url)})
        if audio_record:
            db.audio.update_one(
                {"_id": audio_record["_id"]},
                {
                    "$set": {
                        "transcription": transcription_result["text"],
                        "pronunciation_score": assessment.get("overall_score"),
                        "pronunciation_feedback": assessment
                    }
                }
            )
        
        return PronunciationFeedback(
            overall_score=assessment["overall_score"],
            word_scores=assessment.get("word_scores", {}),
            improvement_suggestions=assessment.get("improvement_suggestions", [])
        )
    
    except Exception as e:
        raise handle_general_exception(e, "pronunciation analysis")


@router.get("/history", response_model=List[AudioResponse])
async def get_audio_history(
    limit: int = 20,
    skip: int = 0,
    current_user: dict = Depends(get_current_user)
):
    """
    Get the user's audio recording history.
    
    Args:
        limit: Maximum number of records to return
        skip: Number of records to skip for pagination
        current_user: Authenticated user information
        
    Returns:
        List of audio records for the user
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Get audio records for the user
        cursor = db.audio.find({"user_id": user_id})
        
        # Apply pagination
        cursor = cursor.sort("created_at", -1).skip(skip).limit(limit)
        
        # Convert to list and format ObjectIds
        result = []
        for audio in cursor:
            audio["_id"] = str(audio["_id"])
            audio["user_id"] = str(audio["user_id"])
            result.append(AudioResponse(**audio))
        
        return result
    
    except Exception as e:
        raise handle_general_exception(e, "audio history")


@router.get("/{audio_id}", response_model=AudioResponse)
async def get_audio(
    audio_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Get a specific audio record by ID.
    
    Args:
        audio_id: ID of the audio record
        current_user: Authenticated user information
        
    Returns:
        The audio record
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Get the audio record
        audio = db.audio.find_one({
            "_id": ObjectId(audio_id),
            "user_id": user_id
        })
        
        if not audio:
            raise get_not_found_exception("Audio", audio_id)
        
        # Format ObjectIds
        audio["_id"] = str(audio["_id"])
        audio["user_id"] = str(audio["user_id"])
        
        return AudioResponse(**audio)
    
    except ValueError:
        raise get_not_found_exception("Audio", audio_id)
    except Exception as e:
        raise handle_general_exception(e, "audio")
