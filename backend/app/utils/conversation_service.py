import logging
from typing import Dict, Any, Optional, List
from datetime import datetime
from bson import ObjectId

from app.config.database import db
from app.models.conversation import Conversation
from app.models.message import Message
from app.utils.conversation_generator import ConversationGenerator

logger = logging.getLogger(__name__)

class ConversationContext:
    """
    Class representing the context of a conversation.
    Used to generate AI responses and provide context for feedback.
    """
    
    def __init__(
        self,
        user_role: str,
        ai_role: str,
        situation: str,
        previous_exchanges: List[Dict[str, Any]] = None
    ):
        self.user_role = user_role
        self.ai_role = ai_role
        self.situation = situation
        self.previous_exchanges = previous_exchanges or []
    
    def get_formatted_context(self) -> Dict[str, Any]:
        """
        Get the context formatted for use in AI models.
        
        Returns:
            Dictionary with formatted context
        """
        # Format previous exchanges
        formatted_exchanges = []
        for exchange in self.previous_exchanges:
            sender = "User" if exchange.get("sender") == "user" else "AI"
            formatted_exchanges.append(f"{sender}: {exchange.get('content', '')}")
        
        return {
            "user_role": self.user_role,
            "ai_role": self.ai_role,
            "situation": self.situation,
            "previous_exchanges": "\n".join(formatted_exchanges)
        }

class ConversationService:
    """
    Service for managing conversations.
    
    This class provides functionality to:
    1. Create new conversations
    2. Retrieve existing conversations
    3. Add messages to conversations
    4. Generate AI responses
    """
    
    def __init__(self):
        self.conversation_generator = ConversationGenerator()
    
    def create_conversation(self, user_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create a new conversation.
        
        Args:
            user_id: ID of the user creating the conversation
            data: Conversation data including roles and situation
            
        Returns:
            The created conversation
            
        Raises:
            ServiceError: If creation fails
        """
        try:
            # Convert string ID to ObjectId
            user_object_id = ObjectId(user_id)
            
            # Enhance scenario if basic
            scenario = data.get("situation", "General conversation")
            enhanced = None
            
            if len(scenario.split()) < 10:  # Basic scenario
                enhanced = self.conversation_generator.enhance_scenario(scenario)
                
                # Update data with enhanced scenario
                if enhanced:
                    data["situation"] = enhanced.get("enhanced_description", scenario)
                    data["user_role"] = enhanced.get("user_role", data.get("user_role", "Student"))
                    data["ai_role"] = enhanced.get("ai_role", data.get("ai_role", "Teacher"))
            
            # Create conversation
            conversation = Conversation(
                user_id=user_object_id,
                user_role=data.get("user_role", "Student"),
                ai_role=data.get("ai_role", "Teacher"),
                situation=data.get("situation", "General conversation")
            )
            
            # Insert into database
            result = db.conversations.insert_one(conversation.to_dict())
            
            # Fetch the inserted conversation
            created_conv = db.conversations.find_one({"_id": result.inserted_id})
            
            # Add initial AI message if available from enhancement
            if enhanced and "starting_message" in enhanced:
                self.add_message(
                    str(result.inserted_id),
                    {
                        "sender": "ai",
                        "content": enhanced.get("starting_message")
                    }
                )
                
                # Refetch with message
                created_conv = db.conversations.find_one({"_id": result.inserted_id})
            
            # Convert ObjectId to string
            created_conv["_id"] = str(created_conv["_id"])
            created_conv["user_id"] = str(created_conv["user_id"])
            
            return created_conv
            
        except Exception as e:
            logger.error(f"Error creating conversation: {str(e)}")
            raise Exception(f"Failed to create conversation: {str(e)}")
    
    def get_conversation(self, conversation_id: str) -> Dict[str, Any]:
        """
        Get a conversation by ID.
        
        Args:
            conversation_id: ID of the conversation to retrieve
            
        Returns:
            The conversation data
            
        Raises:
            ServiceError: If retrieval fails
        """
        try:
            # Convert string ID to ObjectId
            conversation_object_id = ObjectId(conversation_id)
            
            # Get conversation
            conversation = db.conversations.find_one({"_id": conversation_object_id})
            
            if not conversation:
                raise ValueError(f"Conversation with ID {conversation_id} not found")
            
            # Get messages
            messages = list(db.messages.find({"conversation_id": conversation_object_id})
                          .sort("timestamp", 1))
            
            # Convert ObjectIds to strings
            conversation["_id"] = str(conversation["_id"])
            conversation["user_id"] = str(conversation["user_id"])
            
            # Add messages to conversation
            conversation["messages"] = []
            for message in messages:
                message["_id"] = str(message["_id"])
                message["conversation_id"] = str(message["conversation_id"])
                message["user_id"] = str(message["user_id"]) if "user_id" in message else None
                message["feedback_id"] = str(message["feedback_id"]) if "feedback_id" in message else None
                conversation["messages"].append(message)
            
            return conversation
            
        except Exception as e:
            logger.error(f"Error getting conversation: {str(e)}")
            raise Exception(f"Failed to get conversation: {str(e)}")
    
    def add_message(self, conversation_id: str, message_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Add a message to a conversation.
        
        Args:
            conversation_id: ID of the conversation
            message_data: Message data including sender and content
            
        Returns:
            The created message
            
        Raises:
            ServiceError: If addition fails
        """
        try:
            # Convert string ID to ObjectId
            conversation_object_id = ObjectId(conversation_id)
            
            # Get conversation
            conversation = db.conversations.find_one({"_id": conversation_object_id})
            
            if not conversation:
                raise ValueError(f"Conversation with ID {conversation_id} not found")
            
            # Create message
            message = Message(
                conversation_id=conversation_object_id,
                sender=message_data.get("sender", "user"),
                content=message_data.get("content", ""),
                audio_path=message_data.get("audio_path", None),
                transcription=message_data.get("transcription", None)
            )
            
            # Insert into database
            result = db.messages.insert_one(message.to_dict())
            
            # Update conversation's last_updated field
            db.conversations.update_one(
                {"_id": conversation_object_id},
                {"$set": {"last_updated": datetime.utcnow()}}
            )
            
            # Fetch the inserted message
            created_message = db.messages.find_one({"_id": result.inserted_id})
            
            # Convert ObjectIds to strings
            created_message["_id"] = str(created_message["_id"])
            created_message["conversation_id"] = str(created_message["conversation_id"])
            
            # If this is a user message, generate an AI response
            if message_data.get("sender", "user") == "user" and message_data.get("generate_response", True):
                ai_message = self._generate_ai_response(conversation_id)
                
                if ai_message:
                    # Include the AI response in the return data
                    created_message["ai_response"] = ai_message
            
            return created_message
            
        except Exception as e:
            logger.error(f"Error adding message: {str(e)}")
            raise Exception(f"Failed to add message: {str(e)}")
    
    def _generate_ai_response(self, conversation_id: str) -> Optional[Dict[str, Any]]:
        """
        Generate an AI response for a conversation.
        
        Args:
            conversation_id: ID of the conversation
            
        Returns:
            The generated AI message or None if generation fails
        """
        try:
            # Get conversation context
            context = self._get_conversation_context(conversation_id)
            
            if not context:
                return None
            
            # Generate AI response
            response_text = self.conversation_generator.generate_ai_response(context.get_formatted_context())
            
            if not response_text:
                return None
            
            # Create AI message
            message_data = {
                "sender": "ai",
                "content": response_text,
                "generate_response": False  # Prevent infinite loop
            }
            
            # Add message to conversation
            return self.add_message(conversation_id, message_data)
            
        except Exception as e:
            logger.error(f"Error generating AI response: {str(e)}")
            return None
    
    def _get_conversation_context(self, conversation_id: str) -> Optional[ConversationContext]:
        """
        Get the context for a conversation.
        
        Args:
            conversation_id: ID of the conversation
            
        Returns:
            ConversationContext object or None if retrieval fails
        """
        try:
            # Convert string ID to ObjectId
            conversation_object_id = ObjectId(conversation_id)
            
            # Get conversation
            conversation = db.conversations.find_one({"_id": conversation_object_id})
            
            if not conversation:
                return None
            
            # Get last 10 messages
            messages = list(db.messages.find({"conversation_id": conversation_object_id})
                          .sort("timestamp", -1)
                          .limit(10))
            
            # Reverse to get chronological order
            messages.reverse()
            
            # Create context
            return ConversationContext(
                user_role=conversation.get("user_role", "Student"),
                ai_role=conversation.get("ai_role", "Teacher"),
                situation=conversation.get("situation", "General conversation"),
                previous_exchanges=messages
            )
            
        except Exception as e:
            logger.error(f"Error getting conversation context: {str(e)}")
            return None 