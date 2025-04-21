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
        situation=ai_first_response
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
    current_user: dict = Depends(get_current_user)
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
    # Write to a file
    with open("conversation_log.txt", "w") as file:
        file.write("Messages:\n")
        for message in messages:
            file.write(f"{message}\n")
        
        file.write("\nHistory:\n")
        for entry in history:
            file.write(f"{entry}\n")

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

    # Return AI response
    ai_message_dict = ai_message.to_dict()
    ai_message_dict["id"] = str(ai_message_dict["_id"])
    ai_message_dict["conversation_id"] = str(ai_message_dict["conversation_id"])
    del ai_message_dict["_id"]
    return MessageResponse(**ai_message_dict)