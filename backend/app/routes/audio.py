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

@router.post("/upload", response_model=AudioResponse)
async def upload_audio(
    audio: AudioCreate,
    current_user: dict = Depends(get_current_user)
):
    """
    Register a new audio recording in the system using a URL.
    
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
            url=str(audio.url) if audio.url else None,
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


@router.post("/upload-file", response_model=AudioResponse)
async def upload_audio_file(
    file: UploadFile = File(...),
    duration_seconds: Optional[float] = Form(None),
    language: str = Form("en-US"),
    current_user: dict = Depends(get_current_user)
):
    """
    Upload an audio file directly to the server.
    
    Args:
        file: The audio file to upload
        duration_seconds: Duration of the audio in seconds
        language: Language code of the audio content
        current_user: Authenticated user information
        
    Returns:
        The created audio record
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
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
        
        # Create audio record
        new_audio = Audio(
            user_id=user_id,
            filename=file.filename,
            file_path=str(file_path),
            duration_seconds=duration_seconds,
            language=language
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
        raise handle_general_exception(e, "audio file upload")


@router.post("/transcribe", response_model=TranscriptionResponse)
async def transcribe(
    request: TranscriptionRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Transcribe audio content to text using Azure Speech-to-Text.
    
    Args:
        request: Transcription request with audio URL or file ID
        current_user: Authenticated user information
        
    Returns:
        The transcription result
    """
    try:
        # Determine whether we're using a file or URL
        audio_url = None
        audio_record = None
        
        if request.file_id:
            # Get audio record by ID
            audio_record = db.audio.find_one({"_id": ObjectId(request.file_id)})
            if not audio_record:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Audio record with ID {request.file_id} not found"
                )
            
            # Use file path as audio source
            audio_url = audio_record.get("file_path")
            if not audio_url:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="The specified audio record has no file path"
                )
        elif request.audio_url:
            # Use the provided URL
            audio_url = str(request.audio_url)
            # Try to find the record if it exists
            audio_record = db.audio.find_one({"url": audio_url})
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Either file_id or audio_url must be provided"
            )
        
        # Call transcription service
        result = transcribe_audio(
            audio_url=audio_url,
            language_code=request.language
        )
        
        # Update audio record if it exists
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
    Analyze pronunciation quality of an audio recording using Azure Speech Services.
    
    Args:
        request: Audio URL or file ID to analyze
        reference_text: Optional reference text to compare against
        current_user: Authenticated user information
        
    Returns:
        Pronunciation assessment and feedback
    """
    try:
        # Determine whether we're using a file or URL
        audio_url = None
        audio_record = None
        
        if request.file_id:
            # Get audio record by ID
            audio_record = db.audio.find_one({"_id": ObjectId(request.file_id)})
            if not audio_record:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Audio record with ID {request.file_id} not found"
                )
            
            # Use file path as audio source
            audio_url = audio_record.get("file_path")
            if not audio_url:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="The specified audio record has no file path"
                )
        elif request.audio_url:
            # Use the provided URL
            audio_url = str(request.audio_url)
            # Try to find the record if it exists
            audio_record = db.audio.find_one({"url": audio_url})
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Either file_id or audio_url must be provided"
            )
        
        # First transcribe if not already done
        transcription_result = transcribe_audio(
            audio_url=audio_url,
            language_code=request.language
        )
        
        # Get pronunciation assessment
        assessment = assess_pronunciation(
            audio_url=audio_url,
            transcription=transcription_result["text"],
            reference_text=reference_text
        )
        
        # Update audio record if it exists
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


@router.post("/analyze", response_model=AnalysisResponse)
async def comprehensive_analysis(
    request: AnalysisRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Perform comprehensive analysis of spoken English including transcription, 
    pronunciation, and language feedback using Azure Speech Services.
    
    Args:
        request: Analysis request with audio URL or file_id and optional reference text
        current_user: Authenticated user information
        
    Returns:
        Comprehensive analysis results
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Determine whether we're using a file or URL
        audio_url = None
        audio_record = None
        
        if request.file_id:
            # Get audio record by ID
            audio_record = db.audio.find_one({"_id": ObjectId(request.file_id)})
            if not audio_record:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Audio record with ID {request.file_id} not found"
                )
            
            # Use file path as audio source
            audio_url = audio_record.get("file_path")
            if not audio_url:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="The specified audio record has no file path"
                )
        elif request.audio_url:
            # Use the provided URL
            audio_url = str(request.audio_url)
            # Try to find the record if it exists
            audio_record = db.audio.find_one({"url": audio_url})
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Either file_id or audio_url must be provided"
            )
        
        # Perform comprehensive analysis
        result = analyze_spoken_english(
            audio_url=audio_url,
            reference_text=request.reference_text
        )
        
        # Update audio record if it exists
        if audio_record:
            db.audio.update_one(
                {"_id": audio_record["_id"]},
                {
                    "$set": {
                        "transcription": result["transcription"],
                        "pronunciation_score": result["pronunciation"]["overall_score"],
                        "pronunciation_feedback": result["pronunciation"],
                        "language_feedback": result["language_feedback"]
                    }
                }
            )
            
        # Extract mistakes for tracking
        mistakes = extract_mistakes_from_feedback(
            user_id=user_id,
            transcription=result["transcription"],
            pronunciation=result["pronunciation"],
            language_feedback=result["language_feedback"]
        )
            
        return AnalysisResponse(
            transcription=result["transcription"],
            confidence=result["confidence"],
            pronunciation=result["pronunciation"],
            language_feedback=result["language_feedback"]
        )
    
    except Exception as e:
        raise handle_general_exception(e, "comprehensive analysis")


@router.post("/analyze-file", response_model=AnalysisResponse)
async def analyze_uploaded_file(
    request: FileProcessRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Perform comprehensive analysis on an uploaded audio file.
    
    Args:
        request: Analysis request with file ID and optional reference text
        current_user: Authenticated user information
        
    Returns:
        Comprehensive analysis results
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Get audio record by ID
        audio_record = db.audio.find_one({"_id": ObjectId(request.file_id)})
        if not audio_record:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Audio record with ID {request.file_id} not found"
            )
        
        # Use file path as audio source
        file_path = audio_record.get("file_path")
        if not file_path:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="The specified audio record has no file path"
            )
        
        # Perform comprehensive analysis
        result = analyze_spoken_english(
            audio_url=file_path,
            reference_text=request.reference_text
        )
        
        # Update audio record
        db.audio.update_one(
            {"_id": audio_record["_id"]},
            {
                "$set": {
                    "transcription": result["transcription"],
                    "pronunciation_score": result["pronunciation"]["overall_score"],
                    "pronunciation_feedback": result["pronunciation"],
                    "language_feedback": result["language_feedback"]
                }
            }
        )
        
        # Extract mistakes for tracking
        mistakes = extract_mistakes_from_feedback(
            user_id=user_id,
            transcription=result["transcription"],
            pronunciation=result["pronunciation"],
            language_feedback=result["language_feedback"]
        )
            
        return AnalysisResponse(
            transcription=result["transcription"],
            confidence=result["confidence"],
            pronunciation=result["pronunciation"],
            language_feedback=result["language_feedback"]
        )
    
    except Exception as e:
        raise handle_general_exception(e, "file analysis")


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


@router.post("/transcribe-local", response_model=TranscriptionResponse)
async def transcribe_local_file(
    request: LocalFileRequest,
    use_azure_engine: bool = Query(False, description="Use Azure Speech Services instead of local recognition"),
    current_user: dict = Depends(get_current_user)
):
    """
    Transcribe audio content from a local file path.
    
    This endpoint uses local speech recognition by default (faster) and falls back to
    Azure Speech Services only when explicitly requested or if local processing fails.
    
    Args:
        request: Local file request with path to audio file
        use_azure_engine: Whether to use Azure Speech Services instead of local recognition
        current_user: Authenticated user information
        
    Returns:
        The transcription result
    """
    try:
        # Verify file exists
        if not os.path.exists(request.file_path):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Audio file not found at path: {request.file_path}"
            )
        
        # Verify it's an audio file
        file_ext = os.path.splitext(request.file_path)[1].lower()
        if file_ext not in VALID_AUDIO_EXTENSIONS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid audio file extension: {file_ext}. Supported formats: {', '.join(VALID_AUDIO_EXTENSIONS)}"
            )
        
        # Process the audio file
        if use_azure_engine:
            # Use Azure Speech Service
            result = transcribe_audio(
                audio_url=request.file_path,
                language_code=request.language
            )
        else:
            # Use local speech recognition (default)
            try:
                result = transcribe_audio_local(
                    audio_file_path=request.file_path,
                    language_code=request.language
                )
            except Exception as e:
                # Fall back to Azure if local processing fails
                logger.warning(f"Local speech recognition failed: {str(e)}. Falling back to Azure.")
                result = transcribe_audio(
                    audio_url=request.file_path,
                    language_code=request.language
                )
        
        # Optionally create an audio record for the file
        if request.user_id:
            user_id = ObjectId(request.user_id) if request.user_id else ObjectId(current_user["_id"])
            
            # Create audio record
            new_audio = Audio(
                user_id=user_id,
                file_path=request.file_path,
                transcription=result["text"],
                language=request.language
            )
            
            # Insert into database
            db.audio.insert_one(new_audio.to_dict())
        
        return TranscriptionResponse(
            text=result["text"],
            confidence=result.get("confidence")
        )
    
    except Exception as e:
        raise handle_general_exception(e, "local audio transcription")


@router.post("/pronunciation-local", response_model=PronunciationFeedback)
async def analyze_local_pronunciation(
    request: LocalFileRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Analyze pronunciation quality of a local audio file using Azure Speech Services.
    
    Args:
        request: Local file request with path to audio file and optional reference text
        current_user: Authenticated user information
        
    Returns:
        Pronunciation assessment and feedback
    """
    try:
        # Verify file exists
        if not os.path.exists(request.file_path):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Audio file not found at path: {request.file_path}"
            )
        
        # Verify it's an audio file
        file_ext = os.path.splitext(request.file_path)[1].lower()
        if file_ext not in VALID_AUDIO_EXTENSIONS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid audio file extension: {file_ext}. Supported formats: {', '.join(VALID_AUDIO_EXTENSIONS)}"
            )
        
        # First transcribe the audio
        transcription_result = transcribe_audio(
            audio_url=request.file_path,
            language_code=request.language
        )
        
        # Then assess pronunciation
        result = assess_pronunciation(
            audio_url=request.file_path, 
            transcription=transcription_result["text"],
            reference_text=request.reference_text
        )
        
        # Optionally create/update audio record
        if request.user_id:
            user_id = ObjectId(request.user_id) if request.user_id else ObjectId(current_user["_id"])
            
            # Check if record already exists for this file path
            existing_record = db.audio.find_one({"file_path": request.file_path})
            
            if existing_record:
                # Update existing record
                db.audio.update_one(
                    {"_id": existing_record["_id"]},
                    {"$set": {
                        "transcription": transcription_result["text"],
                        "pronunciation_score": result["overall_score"],
                        "pronunciation_feedback": result
                    }}
                )
            else:
                # Create new record
                new_audio = Audio(
                    user_id=user_id,
                    file_path=request.file_path,
                    transcription=transcription_result["text"],
                    language=request.language,
                    pronunciation_score=result["overall_score"],
                    pronunciation_feedback=result
                )
                db.audio.insert_one(new_audio.to_dict())
        
        return PronunciationFeedback(**result)
    
    except Exception as e:
        raise handle_general_exception(e, "local audio pronunciation assessment")


@router.post("/analyze-local", response_model=AnalysisResponse)
async def analyze_local_audio(
    request: LocalFileRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Perform comprehensive analysis of spoken English from a local audio file.
    
    This analysis includes transcription, pronunciation assessment, and language feedback.
    
    Args:
        request: Local file request with path to audio file and optional reference text
        current_user: Authenticated user information
        
    Returns:
        Comprehensive analysis results
    """
    try:
        # Verify file exists
        if not os.path.exists(request.file_path):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Audio file not found at path: {request.file_path}"
            )
        
        # Verify it's an audio file
        file_ext = os.path.splitext(request.file_path)[1].lower()
        if file_ext not in VALID_AUDIO_EXTENSIONS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid audio file extension: {file_ext}. Supported formats: {', '.join(VALID_AUDIO_EXTENSIONS)}"
            )
        
        # Perform comprehensive analysis
        result = analyze_spoken_english(
            audio_url=request.file_path,
            reference_text=request.reference_text
        )
        
        # Optionally create/update audio record
        if request.user_id:
            user_id = ObjectId(request.user_id) if request.user_id else ObjectId(current_user["_id"])
            
            # Check if record already exists for this file path
            existing_record = db.audio.find_one({"file_path": request.file_path})
            
            if existing_record:
                # Update existing record
                db.audio.update_one(
                    {"_id": existing_record["_id"]},
                    {"$set": {
                        "transcription": result["transcription"],
                        "pronunciation_score": result["pronunciation"]["overall_score"],
                        "pronunciation_feedback": result["pronunciation"],
                        "language_feedback": result["language_feedback"]
                    }}
                )
            else:
                # Create new record
                new_audio = Audio(
                    user_id=user_id,
                    file_path=request.file_path,
                    transcription=result["transcription"],
                    language=request.language,
                    pronunciation_score=result["pronunciation"]["overall_score"],
                    pronunciation_feedback=result["pronunciation"],
                    language_feedback=result["language_feedback"]
                )
                db.audio.insert_one(new_audio.to_dict())
        
        return AnalysisResponse(
            transcription=result["transcription"],
            confidence=result["confidence"],
            pronunciation=PronunciationFeedback(**result["pronunciation"]),
            language_feedback=LanguageFeedback(**result["language_feedback"])
        )
    
    except Exception as e:
        raise handle_general_exception(e, "local audio analysis")


@router.post("/save-mic-recording", response_model=AudioResponse)
async def save_microphone_recording(
    file_content: str = Body(..., description="Base64-encoded audio data"),
    filename: str = Body(...),
    language: str = Body("en-US"),
    duration_seconds: Optional[float] = Body(None),
    current_user: dict = Depends(get_current_user)
):
    """
    Save raw microphone recording data directly to a file on the server.
    
    This endpoint is useful for Flutter applications that want to send raw audio 
    data from the microphone without saving it to a file first on the device.
    
    Args:
        file_content: Base64-encoded audio data
        filename: Desired name for the file (will be made unique)
        language: Language code of the audio content
        duration_seconds: Duration of the audio in seconds
        current_user: Authenticated user information
        
    Returns:
        Information about the saved audio file
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Create user directory if it doesn't exist
        user_dir = UPLOAD_DIR / str(user_id)
        user_dir.mkdir(exist_ok=True)
        
        # Generate unique filename
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        safe_filename = f"{timestamp}_{filename.replace(' ', '_')}"
        file_path = user_dir / safe_filename
        
        # Decode base64 data and write to file
        try:
            binary_data = base64.b64decode(file_content)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid base64 data: {str(e)}"
            )
        
        # Write the binary data to a file
        with open(file_path, "wb") as f:
            f.write(binary_data)
        
        # Create audio record
        new_audio = Audio(
            user_id=user_id,
            filename=filename,
            file_path=str(file_path),
            duration_seconds=duration_seconds,
            language=language
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
        raise handle_general_exception(e, "microphone recording save")


@router.post("/analyze-speech", response_model=AnalysisResponse)
async def analyze_speech(
    audio_file: UploadFile = File(...),
    conversation_id: Optional[str] = Form(None),
    current_user: dict = Depends(get_current_user),
    background_tasks: BackgroundTasks = None
):
    """
    Analyze speech to generate grammar and vocabulary feedback and extract mistakes.
    
    This endpoint:
    1. Saves and transcribes the uploaded audio file using local speech recognition
    2. Gets conversation context if available
    3. Generates dual feedback (user-friendly and detailed grammar/vocabulary analysis)
    4. Extracts and stores mistakes in the background
    5. Returns the immediate feedback to the user
    
    Args:
        audio_file: The audio file to analyze
        conversation_id: Optional ID of the conversation for context
        current_user: Authenticated user information
        background_tasks: Background tasks runner (created automatically if not provided)
        
    Returns:
        Analysis response with transcription and feedback
    """
    try:
        # Create background tasks if not provided
        if background_tasks is None:
            background_tasks = BackgroundTasks()
            
        # Get user ID from authenticated user
        user_id = str(current_user["_id"])
        
        # Save the audio file
        file_path = await save_audio_file(audio_file, user_id)
        
        # Transcribe the audio locally
        transcription_result = transcribe_audio_local(file_path)
        if not transcription_result or not transcription_result.get("text"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to transcribe audio. Please try again."
            )
        
        transcription = transcription_result["text"]
        # Get conversation context if needed
        context = None
        if conversation_id:
            # Get conversation from database
            conversation = db.conversations.find_one({"_id": ObjectId(conversation_id)})
            if conversation:
                # Get recent messages for context
                messages_cursor = db.messages.find({"conversation_id": ObjectId(conversation_id)})
                messages_cursor = messages_cursor.sort("timestamp", -1).limit(5)
                messages = list(messages_cursor)
                if messages:
                    logger.debug(f"First message keys: {list(messages[0].keys())}")
                    logger.debug(f"First message content: {messages[0]}")
                context = {
                    "user_role": conversation.get("user_role", "Student"),
                    "ai_role": conversation.get("ai_role", "Teacher"),
                    "situation": conversation.get("situation", "General conversation"),
                   "previous_exchanges": "\n".join([f"{msg.get('sender', 'Unknown')}: {msg.get('content', '')}" for msg in reversed(messages)])
                }
                # {'user_role': 'Student', 'ai_role': 'Teacher', 'situation': 'General conversation', 'previous_exchanges': 'Unknown: \nUnknown: \nUnknown: \nUnknown: \nUnknown: '}
        
        # Generate dual feedback
        from app.utils.feedback_service import FeedbackService
        feedback_service = FeedbackService()
        feedback_result = feedback_service.generate_dual_feedback(
            transcription=transcription,
            context=context
        )
        # Process feedback for mistakes in the background
        from app.utils.mistake_service import MistakeService
        
        mistake_service = MistakeService()
        background_tasks.add_task(
            mistake_service.process_feedback_for_mistakes,
            user_id=user_id,
            transcription=transcription,
            detailed_feedback=feedback_result["detailed_feedback"],
            context=context
        )
        
        # Store the audio and create a record
        audio_record = Audio(
            user_id=ObjectId(user_id),
            filename=audio_file.filename,
            file_path=str(file_path),
            transcription=transcription,
            language="en-US"
        )
        
        # Insert audio record
        result = db.audio.insert_one(audio_record.to_dict())
        audio_id = str(result.inserted_id)
           
        # Store feedback
        grammar_issues = feedback_result["detailed_feedback"].get("grammar_issues", [])
        vocabulary_issues = feedback_result["detailed_feedback"].get("vocabulary_issues", [])
        
        feedback_record = {
            "target_id": ObjectId(audio_id),
            "target_type": "audio",
            "user_id": ObjectId(user_id),
            "user_feedback": feedback_result["user_feedback"],
            "grammar_issues": grammar_issues,
            "vocabulary_issues": vocabulary_issues,
            "created_at": datetime.utcnow()
        }
        
        db.feedback.insert_one(feedback_record)
        
        # Return response
        return {
            "audio_id": audio_id,
            "transcription": transcription,
            "user_feedback": feedback_result["user_feedback"],
            "grammar_issues": grammar_issues,
            "vocabulary_issues": vocabulary_issues,
            "conversation_id": conversation_id
        }
        
    except Exception as e:
        logger.error(f"Error in speech analysis: {str(e)}")
        raise handle_general_exception(e, "speech analysis")

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
