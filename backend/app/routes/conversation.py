from fastapi import APIRouter, Depends, HTTPException
from app.config.database import db
from app.schemas.conversation import ConversationCreate, ConversationResponse
from app.schemas.message import MessageCreate, MessageResponse
from app.models.conversation import Conversation
from app.models.message import Message
from app.utils.auth import get_current_user
from app.utils.gemini import generate_response
from bson import ObjectId

router = APIRouter()

@router.post("/conversations", response_model=dict)
async def create_conversation(convo_data: ConversationCreate, current_user: dict = Depends(get_current_user)):
    new_convo = Conversation(
        user_id=ObjectId(current_user["_id"]),
        user_role=convo_data.user_role,
        ai_role=convo_data.ai_role,
        situation=convo_data.situation
    )
    result = db.conversations.insert_one(new_convo.to_dict())
    conversation_id = result.inserted_id

    initial_prompt = (
        f"You are {convo_data.ai_role}, and the user is {convo_data.user_role}. "
        f"The situation is: {convo_data.situation}. Start the conversation as {convo_data.ai_role}."
    )
    ai_text = generate_response(initial_prompt)
    initial_message = Message(conversation_id=conversation_id, role="ai", text=ai_text)
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
    # Verify conversation exists and belongs to the user
    conversation = db.conversations.find_one({
        "_id": ObjectId(conversation_id),
        "user_id": ObjectId(current_user["_id"])
    })
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")

    # Store user's message
    user_message = Message(
        conversation_id=ObjectId(conversation_id),
        role="user",
        text=message_data.text,
        audio_url=message_data.audio_url
    )
    db.messages.insert_one(user_message.to_dict())

    # Fetch conversation history
    messages = list(db.messages.find({"conversation_id": ObjectId(conversation_id)}).sort("created_at", 1))
    history = [
        {"role": "user" if msg["role"] == "user" else "model", "parts": [msg["text"]]}
        for msg in messages
    ]

    # Include context in the prompt
    prompt = (
        f"You are {conversation['ai_assistant']}, and the user is {conversation['topic'].split(' and ')[0]}. "
        f"The situation is: {conversation['situation_description']}. "
        f"Here's the conversation so far:\n" +
        "\n".join([f"{msg['role']}: {msg['text']}" for msg in messages]) +
        f"\nRespond as {conversation['ai_assistant']}."
    )
    ai_text = generate_response(prompt)

    # Store AI response
    ai_message = Message(conversation_id=ObjectId(conversation_id), role="ai", text=ai_text)
    db.messages.insert_one(ai_message.to_dict())

    # Return AI response
    ai_message_dict = ai_message.to_dict()
    ai_message_dict["id"] = str(ai_message_dict["_id"])
    del ai_message_dict["_id"]
    return MessageResponse(**ai_message_dict)