from fastapi import APIRouter, Depends, HTTPException
from app.config.database import db
from app.schemas.conversation import ConversationCreate, ConversationResponse
from app.schemas.message import MessageCreate, MessageResponse
from app.models.conversation import Conversation
from app.models.message import Message
from app.utils.auth import get_current_user
from app.utils.gemini import generate_response
from bson import ObjectId
import json
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


router = APIRouter()

@router.post("/conversations", response_model=dict)
async def create_conversation(convo_data: ConversationCreate, current_user: dict = Depends(get_current_user)):
    """
    Create a new conversation and generate an initial AI response.
    
    Args:
        convo_data (ConversationCreate): Conversation creation data containing user_role, ai_role, and situation.
            Sample input:
            {
                "user_role": "a job seeker",
                "ai_role": "an experienced interviewer",
                "situation": "preparing for a software engineering job interview"
            }
        current_user (dict): The authenticated user's information.
            Sample input:
            {
                "_id": "507f1f77bcf86cd799439011",
                "name": "John Doe",
                "email": "john@example.com"
            }
        
    Returns:
        dict: A dictionary containing the conversation and initial message.
            Sample output:
            {
                "conversation": {
                    "id": "507f1f77bcf86cd799439012",
                    "user_id": "507f1f77bcf86cd799439011",
                    "user_role": "a job seeker",
                    "ai_role": "an experienced interviewer",
                    "situation": "preparing for a software engineering job interview",
                    "created_at": "2024-04-04T12:00:00"
                },
                "initial_message": {
                    "id": "507f1f77bcf86cd799439013",
                    "conversation_id": "507f1f77bcf86cd799439012",
                    "role": "ai",
                    "text": "Hello! I'll be your interviewer today...",
                    "created_at": "2024-04-04T12:00:00"
                }
            }
            
    Raises:
        HTTPException: If there are any errors during conversation creation.
    """

    # refine the promt to make it more accurate and complete or make sense
    promt_to_refine_roles_and_situation = f"""
        You are an AI assistant designed to engage in role-playing scenarios to help new, intermediate English learners in a natural, real-life conversation. You will be provided with a user role, an AI role, and a situation. These inputs may be incomplete, vague, or inconsistent. Your task is to:

        Analyze the given user role, AI role, and situation.

        Refine them to create a coherent and logical scenario. This may involve:
    
        Adjusting roles or situations that don't make sense together (e.g., if the roles and situation are incompatible, modify them to align).

        Making assumptions where necessary to create a plausible context.

        Use word choice that matches new and intermediate levels, which means it's common and close to real-life.

        User role and AI role: 1-2 words. 

        Once you have a refined scenario, generate an appropriate initial response as the AI in that scenario.

        Return the refined roles, situation, and response as a JSON object.

        Return your output in the following JSON format:
        {{
        "refined_user_role": "[your refined user role]",
        "refined_ai_role": "[your refined AI role]",
        "refined_situation": "[your refined situation]",
        "response": "[your generated response]"
        }}

        Here are the inputs:
        User role: {convo_data.user_role}
        AI role:  {convo_data.ai_role}
        Situation: {convo_data.situation}
        """
    # generate the refined response
    refined_reponse = generate_response(promt_to_refine_roles_and_situation)


    # Clean the response text by removing markdown formatting
    cleaned_text = refined_reponse.strip()
    if cleaned_text.startswith("```json"):
        cleaned_text = cleaned_text[7:]  # Remove ```json prefix
    if cleaned_text.endswith("```"):
        cleaned_text = cleaned_text[:-3]  # Remove ``` suffix
    cleaned_text = cleaned_text.strip()
    # parse the json
    data_json = json.loads(cleaned_text)
    
    refined_user_role = data_json["refined_user_role"]
    refined_ai_role = data_json["refined_ai_role"]
    refined_situation = data_json["refined_situation"]
    ai_first_response = data_json["response"]

    # Get user ID from the current_user dictionary
    user_id = current_user.get("_id")
    if not user_id:
        raise HTTPException(status_code=500, detail="User ID not found in token")

    new_convo = Conversation(
        user_id=ObjectId(user_id),
        user_role=refined_user_role,
        ai_role=refined_ai_role,
        situation=refined_situation
    )
    result = db.conversations.insert_one(new_convo.to_dict())
    conversation_id = result.inserted_id

    
    # create the initial ai message first
    initial_message = Message(
        conversation_id=conversation_id, 
        sender="ai", 
        content=ai_first_response
    )
    db.messages.insert_one(initial_message.to_dict())

    # Fetch the conversation and convert ObjectId fields to strings
    created_convo = db.conversations.find_one({"_id": conversation_id})
    created_convo["id"] = str(created_convo["_id"])
    created_convo["user_id"] = str(created_convo["user_id"])  # Convert user_id to string
    del created_convo["_id"]

    initial_message_dict = initial_message.to_dict()
    initial_message_dict["id"] = str(initial_message_dict["_id"])
    initial_message_dict["conversation_id"] = str(initial_message_dict["conversation_id"])
    del initial_message_dict["_id"]

    # Fetch conversation history
    messages = list(db.messages.find({"conversation_id": ObjectId(conversation_id)}).sort("timestamp", 1))
    history = [
        {"role": "user" if msg["sender"] == "user" else "model", "parts": [msg["content"]]}
        for msg in messages
    ]

    return {
        "conversation": ConversationResponse(**created_convo),
        "initial_message": MessageResponse(**initial_message_dict)
    }


@router.post("/conversations/{conversation_id}/messages", response_model=MessageResponse)
async def send_message(
    conversation_id: str,
    message_data: MessageCreate,
    current_user: dict = Depends(get_current_user),
    background_tasks: BackgroundTasks = BackgroundTasks()
):
    """
    Send a message in an existing conversation and get the AI's response.
    
    Args:
        conversation_id (str): The ID of the conversation to send the message in.
            Sample input: "507f1f77bcf86cd799439012"
        message_data (MessageCreate): The message data containing content and optional fields.
            Sample input:
            {
                "content": "Tell me about your experience with Python",
                "audio_path": "https://storage.example.com/audio/123.mp3",  # optional
                "transcription": "Tell me about your experience with Python",  # optional
                "feedback_id": "507f1f77bcf86cd799439015"  # optional
            }
        current_user (dict): The authenticated user's information.
            Sample input:
            {
                "_id": "507f1f77bcf86cd799439011",
                "name": "John Doe",
                "email": "john@example.com"
            }
        background_tasks: FastAPI background tasks manager for processing feedback
        
    Returns:
        MessageResponse: The AI's response message.
            Sample output:
            {
                "id": "507f1f77bcf86cd799439014",
                "conversation_id": "507f1f77bcf86cd799439012",
                "sender": "ai",
                "content": "I have extensive experience with Python...",
                "timestamp": "2024-04-04T12:05:00",
                "audio_path": null,
                "transcription": null,
                "feedback_id": null
            }
        
    Raises:
        HTTPException: If the conversation is not found (404) or other errors occur.
    """
    try:
        # Get user ID from the current_user dictionary
        user_id = current_user.get("_id")
        if not user_id:
            raise HTTPException(status_code=500, detail="User ID not found in token")
        
        # Verify conversation exists and belongs to the user
        conversation = db.conversations.find_one({
            "_id": ObjectId(conversation_id),
            "user_id": ObjectId(user_id)
        })
        if not conversation:
            raise HTTPException(status_code=404, detail="Conversation not found")

        # Store user's message
        user_message = Message(
            conversation_id=ObjectId(conversation_id),
            sender="user",
            content=message_data.content,
            audio_path=message_data.audio_path,
            transcription=message_data.transcription,
            feedback_id=message_data.feedback_id
        )
        db.messages.insert_one(user_message.to_dict())

        # Fetch conversation history
        messages = list(db.messages.find({"conversation_id": ObjectId(conversation_id)}).sort("timestamp", 1))
        history = [
            {"role": "user" if msg["sender"] == "user" else "model", "parts": [msg["content"]]}
            for msg in messages
        ]

        # Include context in the prompt 
        prompt = (
            f"You are {conversation['ai_role']}, and the user is {conversation['user_role']}. "
            f"The situation is: {conversation['situation']}. "
            f"Here's the conversation so far:\n" +
            "\n".join([f"{msg['sender']}: {msg['content']}" for msg in messages]) +
            f"\nRespond as {conversation['ai_role']}."
        )

        ai_text = generate_response(prompt)

        # Store AI response
        ai_message = Message(conversation_id=ObjectId(conversation_id), sender="ai", content=ai_text)
        db.messages.insert_one(ai_message.to_dict())

        # Process feedback in the background for the user's message
        if message_data.content and message_data.content.strip():
            background_tasks.add_task(
                process_text_feedback,
                message_content=message_data.content,
                user_id=str(user_id),
                conversation_id=conversation_id,
                user_message_id=str(user_message._id)
            )

        # Return AI response
        ai_message_dict = ai_message.to_dict()
        ai_message_dict["id"] = str(ai_message_dict["_id"])
        ai_message_dict["conversation_id"] = str(ai_message_dict["conversation_id"])
        del ai_message_dict["_id"]
        return MessageResponse(**ai_message_dict)
    except Exception as e:
        logger.error(f"Error sending message: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to send message: {str(e)}"
        )


@router.post("/conversations/{conversation_id}/speechtomessage", response_model=MessageResponse)
async def analyze_speech(
    conversation_id: str,  # Path parameter, not a Form parameter
    audio_file: UploadFile = File(...),
    current_user: dict = Depends(get_current_user),
    background_tasks: BackgroundTasks = BackgroundTasks()
):
    """
    Process speech audio and return an AI response.
    
    This simplified endpoint:
    1. Transcribes the uploaded audio file
    2. Saves the audio file to disk
    3. Adds the transcribed text as a user message to the conversation
    4. Generates an AI response to the user's message
    5. Handles feedback generation in the background
    
    Args:
        audio_file: The audio file containing user speech
        conversation_id: ID of the conversation (required)
        current_user: Authenticated user information
        background_tasks: FastAPI background tasks manager
        
    Returns:
        MessageResponse: The AI's response message
    """
    try:
        user_id = str(current_user["_id"])
        
        # Initialize services
        from app.utils.speech_service import SpeechService
        speech_service = SpeechService()
        
        # Verify conversation exists and belongs to the user
        conversation = db.conversations.find_one({
            "_id": ObjectId(conversation_id),
            "user_id": ObjectId(user_id)
        })
        if not conversation:
            raise HTTPException(status_code=404, detail="Conversation not found")
        
        # Step 1: Save the audio file
        file_path, audio_model = speech_service.save_audio_file(audio_file, user_id)
        audio_id = str(audio_model._id)
        
        # Step 2: Transcribe the audio file
        transcription = speech_service.transcribe_audio(Path(file_path))
        
        # Ensure we have a valid transcription to work with
        if not transcription or not transcription.strip():
            logger.warning(f"Empty transcription result for file: {file_path}, using placeholder")
            transcription = "Audio content could not be transcribed. Please try again with a different file format or check audio quality."
            # Return early with an error message as AI response
            ai_message = Message(
                conversation_id=ObjectId(conversation_id), 
                sender="ai", 
                content="I couldn't understand that audio. Could you try again with a clearer recording or different file format?"
            )
            db.messages.insert_one(ai_message.to_dict())
            ai_message_dict = ai_message.to_dict()
            ai_message_dict["id"] = str(ai_message_dict["_id"])
            ai_message_dict["conversation_id"] = str(ai_message_dict["conversation_id"])
            del ai_message_dict["_id"]
            return MessageResponse(**ai_message_dict)
        
        # Update audio record with transcription
        db.audio.update_one(
            {"_id": ObjectId(audio_id)},
            {"$set": {"transcription": transcription}}
        )
        
        # Step 3: Store user's message with transcribed content
        user_message = Message(
            conversation_id=ObjectId(conversation_id),
            sender="user",
            content=transcription,
            audio_path=str(file_path),
            transcription=transcription
        )
        db.messages.insert_one(user_message.to_dict())
        
        # Fetch conversation history
        messages = list(db.messages.find({"conversation_id": ObjectId(conversation_id)}).sort("timestamp", 1))
        
        # Include context in the prompt 
        prompt = (
            f"You are {conversation['ai_role']}, and the user is {conversation['user_role']}. "
            f"The situation is: {conversation['situation']}. "
            f"Here's the conversation so far:\n" +
            "\n".join([f"{msg['sender']}: {msg['content']}" for msg in messages]) +
            f"\nRespond as {conversation['ai_role']}."
        )
        
        # Generate AI response
        ai_text = generate_response(prompt)
        
        # Store AI response
        ai_message = Message(conversation_id=ObjectId(conversation_id), sender="ai", content=ai_text)
        db.messages.insert_one(ai_message.to_dict())
        
        # Process feedback in the background without blocking the response
        background_tasks.add_task(
            process_speech_feedback,
            transcription=transcription,
            user_id=user_id,
            conversation_id=conversation_id,
            audio_id=audio_id,
            file_path=file_path,
            user_message_id=str(user_message._id)
        )
        
        # Return AI response in MessageResponse format
        ai_message_dict = ai_message.to_dict()
        ai_message_dict["id"] = str(ai_message_dict["_id"])
        ai_message_dict["conversation_id"] = str(ai_message_dict["conversation_id"])
        del ai_message_dict["_id"]
        return MessageResponse(**ai_message_dict)
        
    except Exception as e:
        logger.error(f"Error analyzing speech: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to analyze speech: {str(e)}"
        )

async def process_speech_feedback(
    transcription: str,
    user_id: str,
    conversation_id: str,
    audio_id: str,
    file_path: str,
    user_message_id: str
):
    """
    Process speech feedback in the background.
    
    This function handles the feedback generation and storing part that
    was separated from the main speech analysis to allow quick responses.
    """
    try:
        # Initialize services
        from app.utils.feedback_service import FeedbackService
        from app.utils.event_handler import event_handler
        from app.models.results.feedback_result import FeedbackResult
        
        feedback_service = FeedbackService()
        
        # Fetch conversation context
        context = {}
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
        
        # Generate feedback
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
        
        # Store feedback
        feedback_id = feedback_service.store_feedback(
            user_id, 
            feedback_result, 
            conversation_id,
            transcription=transcription
        )
        
        # Link feedback to message
        if feedback_id:
            db.messages.update_one(
                {"_id": ObjectId(user_message_id)},
                {"$set": {"feedback_id": feedback_id}}
            )
            
            # Trigger background task for mistake extraction
            event_handler.on_new_feedback(
                feedback_id,
                user_id,
                transcription
            )
            
    except Exception as e:
        logger.error(f"Error processing speech feedback in background: {str(e)}", exc_info=True)

async def process_text_feedback(
    message_content: str,
    user_id: str,
    conversation_id: str,
    user_message_id: str
):
    """
    Process text feedback in the background.
    
    This function analyzes text messages for language feedback similar to how
    audio messages are processed. It generates grammar and vocabulary feedback
    and extracts mistakes for future learning opportunities.
    
    Args:
        message_content: The content of the user's message
        user_id: User's ID
        conversation_id: ID of the conversation
        user_message_id: ID of the user's message to attach feedback to
    """
    try:
        # Initialize services
        from app.utils.feedback_service import FeedbackService
        from app.utils.event_handler import event_handler
        from app.models.results.feedback_result import FeedbackResult
        
        feedback_service = FeedbackService()
        
        # Fetch conversation context
        context = {}
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
        
        # Generate feedback
        try:
            feedback_result = feedback_service.generate_dual_feedback(message_content, context)
        except Exception as e:
            logger.error(f"Error generating text feedback: {str(e)}", exc_info=True)
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
        
        # Store feedback
        feedback_id = feedback_service.store_feedback(
            user_id, 
            feedback_result, 
            conversation_id,
            transcription=message_content  # Use message content as transcription for text messages
        )
        
        # Link feedback to message
        if feedback_id:
            db.messages.update_one(
                {"_id": ObjectId(user_message_id)},
                {"$set": {"feedback_id": feedback_id}}
            )
            
            # Trigger background task for mistake extraction
            event_handler.on_new_feedback(
                feedback_id,
                user_id,
                message_content
            )
            
    except Exception as e:
        logger.error(f"Error processing text feedback in background: {str(e)}", exc_info=True)

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

@router.get("/messages/{message_id}/feedback")
async def get_message_feedback(
    message_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Get user-friendly feedback for a specific message.
    
    This endpoint retrieves the stored feedback for a message when the user
    clicks the feedback button in the UI.
    
    Args:
        message_id: ID of the message to get feedback for
        current_user: Authenticated user information
        
    Returns:
        dict: User-friendly feedback
    """
    try:
        user_id = str(current_user["_id"])
        
        # Find the message
        message = db.messages.find_one({"_id": ObjectId(message_id)})
        if not message:
            raise HTTPException(status_code=404, detail="Message not found")
        
        # Check if message has associated feedback
        feedback_id = message.get("feedback_id")
        if not feedback_id:
            # Feedback might still be processing
            return {"user_feedback": "Feedback is still being generated. Please try again in a moment."}
        
        # Get the feedback document
        feedback = db.feedback.find_one({"_id": ObjectId(feedback_id)})
        if not feedback:
            return {"user_feedback": "No feedback available for this message."}
        
        # Return only the user-friendly feedback
        return {"user_feedback": feedback.get("user_feedback", "No detailed feedback available.")}
        
    except Exception as e:
        logger.error(f"Error getting message feedback: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get message feedback: {str(e)}"
        )

@router.post("/transcribe-url", response_model=TranscriptionResponse)
async def transcribe_url(
    url: str = Body(..., embed=True),
    language_code: str = Body("en-US", embed=True),
    current_user: dict = Depends(get_current_user)
):
    """
    Transcribe audio from a URL.
    
    This endpoint:
    1. Downloads the audio file from the provided URL
    2. Transcribes the audio content
    3. Returns the transcription without storing it in the conversation
    
    Args:
        url: URL of the audio file to transcribe
        language_code: Language code for transcription (default: en-US)
        current_user: Authenticated user information
        
    Returns:
        TranscriptionResponse: Contains the transcribed text and confidence score
    """
    try:
        user_id = str(current_user["_id"])
        
        # Initialize services
        from app.utils.speech_service import SpeechService
        import tempfile
        import requests
        
        speech_service = SpeechService()
        
        # Download the file from the URL
        response = requests.get(url, stream=True)
        if response.status_code != 200:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to download audio file from URL: {response.status_code}"
            )
            
        # Extract file extension from URL or default to .mp3
        import os
        from urllib.parse import urlparse
        
        parsed_url = urlparse(url)
        path = parsed_url.path
        file_extension = os.path.splitext(path)[1].lower()
        
        if not file_extension or file_extension not in VALID_AUDIO_EXTENSIONS:
            file_extension = ".mp3"  # Default to mp3 if no valid extension found
            
        # Create a temporary file to store the downloaded content
        with tempfile.NamedTemporaryFile(suffix=file_extension, delete=False) as temp_file:
            for chunk in response.iter_content(chunk_size=8192):
                temp_file.write(chunk)
            temp_file_path = temp_file.name
            
        # Transcribe the audio file
        transcription = speech_service.transcribe_audio(Path(temp_file_path), language_code)
        
        # Clean up the temporary file
        os.unlink(temp_file_path)
        
        # Ensure we have a valid transcription
        if not transcription or not transcription.strip():
            return TranscriptionResponse(
                text="Audio content could not be transcribed. Please try again with a different file format or check audio quality.",
                confidence=0.0
            )
            
        # Return the transcription
        return TranscriptionResponse(
            text=transcription,
            confidence=0.8  # Default confidence since local transcription doesn't always provide one
        )
        
    except Exception as e:
        logger.error(f"Error transcribing audio from URL: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to transcribe audio from URL: {str(e)}"
        )
