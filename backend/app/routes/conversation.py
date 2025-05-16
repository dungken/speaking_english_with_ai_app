from fastapi import APIRouter, Depends, HTTPException
from app.config.database import db
from app.schemas.conversation import ConversationCreate, ConversationResponse
from app.schemas.message import MessageCreate, MessageResponse
from app.models.conversation import Conversation
from app.models.message import Message
from app.utils.auth import get_current_user
from app.utils.gemini import generate_response
from app.utils.transcription_error_message import TranscriptionErrorMessages
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

logging.basicConfig(level=logging.INFO)


# Create a file handler for our logs
# Use existing logs directory under the backend folder
file_handler = logging.FileHandler("app/logs/conversation_logs.txt")
file_handler.setLevel(logging.INFO)


# Add the handler to the logger
logger.addHandler(file_handler)

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
        "response": "[your first  response as refined_ai_role to the user regardless of the situation]"
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
    logger.info(f"Refined response: {cleaned_text}")
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


            
            
            

@router.post("/audio2text", response_model=dict)
async def turn_to_text(
    audio_file: UploadFile = File(...),
    current_user: dict = Depends(get_current_user),
):
    """
    Converts an uploaded audio file to text using speech recognition.
    
    Args:
        audio_file (UploadFile): The audio file to transcribe.
            Supported formats include: mp3, wav, m4a, aac, ogg, flac
        current_user (dict): The authenticated user's information.
            Fields:
            - _id: User's ObjectId
            - email: User's email
            - role: User's role
    
    Returns:
        dict: A dictionary containing:
            - audio_id: The ID of the saved audio record (if successful)
            - transcription: The transcribed text or an error message
            - success: Boolean indicating whether transcription was successful
    """
    # Initialize services
    from app.utils.speech_service import SpeechService
    speech_service = SpeechService()
    user_id = str(current_user["_id"])
    
    # Step 1: Try to transcribe the audio from a temporary file
    transcription, temp_file_path = speech_service.transcribe_from_upload(audio_file)
    
    # Step 2: Check if transcription was successful
    transcription_successful = transcription != TranscriptionErrorMessages.DEFAULT_FALLBACK_ERROR.value and transcription != TranscriptionErrorMessages.EMPTY_TRANSCRIPTION.value
    
    # Step 3: If transcription was successful, save the file permanently
    if transcription_successful:
        try:
            # Reset file pointer to beginning of file for save operation
            audio_file.file.seek(0)
            
            # Now save the audio file permanently since transcription was successful
            file_path, audio_model = speech_service.save_audio_file(audio_file, user_id)
            audio_id = str(audio_model._id)
            
            # Update audio record with transcription
            db.audio.update_one(
                {"_id": ObjectId(audio_id)},
                {"$set": {"transcription": transcription, "has_error": False}}
            )
            
            # Clean up the temporary file since we've saved it properly now
            import os
            if temp_file_path and os.path.exists(temp_file_path):
                os.unlink(temp_file_path)
                
            # Return success response
            return {
                "audio_id": audio_id,
                "transcription": transcription,
                "success": True
            }
            
        except Exception as e:
            logger.error(f"Error saving audio after successful transcription: {str(e)}")
            # Even if saving fails, return the transcription to the user
            return {
                "audio_id": None,
                "transcription": transcription,
                "success": True,
                "warning": "Transcription successful but audio storage failed"
            }
    else:
        # Transcription failed - clean up temp file and return error
        if temp_file_path:
            import os
            if os.path.exists(temp_file_path):
                os.unlink(temp_file_path)
                
        # Return error response with consistent format
        return {
            "audio_id": None,
            "transcription": transcription,
            "success": False
        }
        
 

@router.post("/conversations/{conversation_id}/message", response_model=dict)
async def analyze_speech(
    conversation_id: str,  # Path parameter, not a Form parameter
    audio_id: str ,  
    current_user: dict = Depends(get_current_user),
    background_tasks: BackgroundTasks = BackgroundTasks()
):
    """
    Process speech audio and return an AI response.
    
    This endpoint:
    1. Retrieves the transcribed audio using the provided audio_id
    2. Adds the user's message to the conversation
    3. Generates an AI response based on conversation context
    4. Handles feedback generation in the background
    
    Args:
        conversation_id (str): ID of the conversation
            Path parameter identifying which conversation to add the message to
        audio_id (str): The ID of a previously uploaded and transcribed audio file
            This should be an ID returned from the /audio2text endpoint
        current_user (dict): The authenticated user's information
            Fields:
            - _id: User's ObjectId
            - email: User's email
            - role: User's role
        background_tasks (BackgroundTasks): FastAPI background tasks manager
            Used to process feedback generation asynchronously
        
    Returns:
        dict: Dictionary containing both the user's message and the AI's response
            Fields:
            - user_message: MessageResponse object with the transcribed user message
            - ai_message: MessageResponse object with the AI's generated response
            
            Each MessageResponse contains:
            - id: Message ID
            - conversation_id: ID of the conversation
            - sender: "user" or "ai"
            - content: The message text
            - timestamp: When the message was created
            - additional fields like audio_path, transcription (for user messages)
    """
    try:
        user_id = str(current_user["_id"])
        audio_data = db.audio.find_one({"_id": ObjectId(audio_id)})
        
      
        # Verify conversation exists and belongs to the user
        conversation = db.conversations.find_one({
            "_id": ObjectId(conversation_id),
            "user_id": ObjectId(user_id)
        })
   
        if not conversation:
            raise HTTPException(status_code=404, detail="Conversation not found")
        
    
      
        # Step 3: Store user's message with transcribed content
        user_message = Message(
            conversation_id=ObjectId(conversation_id),
            sender="user",
            content=audio_data["transcription"],
            audio_path=audio_data["file_path"],
            transcription=audio_data["transcription"]
        )
        db.messages.insert_one(user_message.to_dict())
        
        # Fetch conversation history
        messages = list(db.messages.find({"conversation_id": ObjectId(conversation_id)}).sort("timestamp", 1))
        
        # Include context in the prompt 
        prompt = (
        f"You are playing the role of {conversation['ai_role']} and the user is {conversation['user_role']}. "
        f"The situation is: {conversation['situation']}. "
        f"Stay fully in character as {conversation['ai_role']}. "
        f"Use natural, simple English that new and intermediate learners can easily understand. "
        f"Keep your response short and friendly (1 to 3 sentences). "
        f"Avoid special characters like brackets or symbols. "
        f"Do not refer to the user with any placeholder like a name in brackets. "
        f"Ask an open-ended question that fits the situation and encourages the user to speak more."
        f"\nHere is the conversation so far:\n" +
        "\n".join([f"{msg['sender']}: {msg['content']}" for msg in messages]) +
        f"\nNow respond as {conversation['ai_role']}."
        )


        
        # Generate AI response
        ai_text = generate_response(prompt)
        
        # Store AI response
        ai_message = Message(conversation_id=ObjectId(conversation_id), sender="ai", content=ai_text)
        db.messages.insert_one(ai_message.to_dict())
        
        # Process feedback in the background without blocking the response
        background_tasks.add_task(
            process_speech_feedback,
            transcription=audio_data["transcription"],
            user_id=user_id,
            conversation_id=conversation_id,
            audio_id=audio_data["_id"],
            file_path=audio_data["file_path"],
            user_message_id=str(user_message._id)
        )
        
        # Return AI response in MessageResponse format
        ai_message_dict = ai_message.to_dict()
        ai_message_dict["id"] = str(ai_message_dict["_id"])
        ai_message_dict["conversation_id"] = str(ai_message_dict["conversation_id"])
        del ai_message_dict["_id"]
        
        user_message_dict = user_message.to_dict()
        user_message_dict["id"] = str(user_message_dict["_id"])
        user_message_dict["conversation_id"] = str(user_message_dict["conversation_id"])
        del user_message_dict["_id"]
        
        return {
            "user_message": MessageResponse(**user_message_dict),
            "ai_message": MessageResponse(**ai_message_dict)
        }
    
       
    except Exception as e:
        logger.error(f"Error /conversations/{conversation_id}/speechtomessage: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed at /conversations/{conversation_id}/speechtomessage: {str(e)}"
        )

@router.get("/messages/{message_id}/feedback",response_model=dict)
async def get_message_feedback(
    message_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Get user-friendly feedback for a specific message.
    
    This endpoint retrieves the stored feedback for a message when the user
    clicks the feedback button in the UI.
    
    Args:
        message_id (str): ID of the message to get feedback for
            Path parameter that identifies which message's feedback to retrieve
        current_user (dict): Authenticated user information
            Fields:
            - _id: User's ObjectId
            - email: User's email
            - role: User's role
        
    Returns:
        dict: User-friendly feedback information
            Fields:
            - user_feedback: Either a string message (if feedback is not ready)
              or a dictionary containing the feedback details
            - is_ready: Boolean indicating if the feedback generation is complete
            
            When feedback is ready (is_ready=True), user_feedback contains:
            - id: Feedback document ID
            - user_feedback: Human-readable feedback text
            - created_at: Timestamp when feedback was generated
    """
    try:
        # Log the entry point with message ID for tracking
        logger.info(f"Fetching feedback for message_id: {message_id}")
        
        user_id = str(current_user["_id"])
        # Find the message
        message = db.messages.find_one({"_id": ObjectId(message_id)})
        if not message:
            logger.warning(f"Message not found: {message_id}")
            raise HTTPException(status_code=404, detail="Message not found")
        
        logger.info(f"Message found: {message_id}, checking for feedback_id")
        
        # Check if message has associated feedback
        feedback_id = message.get("feedback_id")
        if not feedback_id:
            logger.info(f"No feedback_id found for message: {message_id}, feedback may still be processing")
            # Feedback might still be processing
            return {"user_feedback": "Feedback is still being generated. Please try again in a moment.", "is_ready": False}
        
        logger.info(f"Found feedback_id: {feedback_id}, retrieving feedback document")
        
        # Get the feedback document
        try:
            feedback = db.feedback.find_one({"_id": ObjectId(feedback_id)})
            # Log the structure of the feedback document to understand its contents
            logger.info(f"Feedback document structure: {type(feedback).__name__}, keys: {list(feedback.keys()) if feedback else 'None'}")
        except Exception as e:
            logger.error(f"Error retrieving feedback document: {str(e)}", exc_info=True)
            return {"user_feedback": "Error retrieving feedback. Please try again later.", "is_ready": False}
            
        if not feedback:
            logger.warning(f"No feedback found with ID: {feedback_id}")
            return {"user_feedback": "No feedback available for this message.", "is_ready": False}
            
        # Handle feedback document safely
        try:
            # Create a safe copy with only the fields we need
            logger.info(f"Processing feedback document with keys: {list(feedback.keys())}")
            
            feedback_dict = {
                "id": str(feedback.get("_id", "")),
                "user_feedback": feedback.get("user_feedback", "Feedback content unavailable"),
                "created_at": feedback.get("created_at", datetime.now().isoformat())
            }
            
            # Add detailed feedback if available
          
            return {"user_feedback": feedback_dict, "is_ready": True}
        except Exception as e:
            logger.error(f"Error processing feedback document: {str(e)}", exc_info=True)
            return {"user_feedback": "Error processing feedback data. Please try again later.", "is_ready": False}
        
    except Exception as e:
        logger.error(f"Error getting message feedback: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get message feedback: {str(e)}"
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
    
    Args:
        transcription (str): The transcribed text from the audio
            The text content that will be analyzed for feedback
        user_id (str): ID of the user who submitted the audio
            Used to associate feedback with the user
        conversation_id (str): ID of the conversation
            Used to fetch conversation context for better feedback
        audio_id (str): ID of the stored audio record
            References the audio file in the database
        file_path (str): Path to the saved audio file
            Location of the audio file on disk
        user_message_id (str): ID of the user's message
            Used to link the generated feedback to the message
    
    Returns:
        None: This is a background task that doesn't return a value directly
        
    Side Effects:
        - Creates a feedback record in the database
        - Updates the user's message with the feedback_id
        - Triggers mistake extraction for learning purposes
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
            user_message_id,
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

async def save_audio_file(file: UploadFile, user_id: str) -> str:
    """
    Save an uploaded audio file to the server.
    
    Args:
        file (UploadFile): The audio file to save
            FastAPI UploadFile object containing the audio data
        user_id (str): ID of the user
            Used to create user-specific directories for organization
        
    Returns:
        str: Path to the saved file on disk
            Absolute file path that can be used to access the file later
    
    Side Effects:
        - Creates a user directory if it doesn't exist
        - Writes the audio file to disk with a timestamped filename
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

# Add this temporary debugging endpoint
@router.get("/debug/feedback/{feedback_id}", include_in_schema=False)
async def debug_feedback_structure(
    feedback_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Debug endpoint to examine the structure of a feedback document.
    This is a temporary endpoint for debugging purposes.
    
    Args:
        feedback_id (str): ID of the feedback document to examine
            Path parameter identifying which feedback document to retrieve
        current_user (dict): The authenticated user's information
            Fields:
            - _id: User's ObjectId
            - email: User's email
            - role: User's role
    
    Returns:
        dict: Information about the feedback document structure
            Fields:
            - document_type: Python type of the feedback document
            - has_keys: List of keys present in the document
            - id_type: Type of the document's _id field
            - user_feedback_type: Type of the user_feedback field if present
            - detailed_feedback_type: Type of the detailed_feedback field if present
            - detailed_feedback_keys: Keys within the detailed_feedback object
            - raw_feedback: The complete feedback document
            
            Or in case of error:
            - error: Error message
            - traceback: Error traceback information
    """
    try:
        feedback = db.feedback.find_one({"_id": ObjectId(feedback_id)})
        if not feedback:
            return {"error": "Feedback not found"}
            
        # Return basic info about the document
        return {
            "document_type": type(feedback).__name__,
            "has_keys": list(feedback.keys()),
            "id_type": type(feedback.get("_id")).__name__,
            "user_feedback_type": type(feedback.get("user_feedback", None)).__name__ if feedback.get("user_feedback") else None,
            "detailed_feedback_type": type(feedback.get("detailed_feedback", None)).__name__ if feedback.get("detailed_feedback") else None,
            "detailed_feedback_keys": list(feedback.get("detailed_feedback", {}).keys()) if isinstance(feedback.get("detailed_feedback"), dict) else None,
            "raw_feedback": feedback
        }
    except Exception as e:
        return {"error": str(e), "traceback": str(e.__traceback__)}
