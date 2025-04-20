from fastapi import APIRouter, Depends, HTTPException, status
from bson import ObjectId
from typing import List, Optional

from app.config.database import db
from app.models.feedback import Feedback
from app.models.mistake import Mistake
from app.schemas.feedback import FeedbackCreate, FeedbackResponse, FeedbackRequest
from app.utils.auth import get_current_user
from app.utils.audio_processor import generate_feedback
from app.utils.error_handler import get_not_found_exception, handle_general_exception

router = APIRouter()

@router.post("/generate", response_model=FeedbackResponse)
async def generate_message_feedback(
    request: FeedbackRequest,
    target_id: Optional[str] = None,
    target_type: str = "message",
    current_user: dict = Depends(get_current_user)
):
    """
    Generate feedback for user's text or audio and save it.
    
    Args:
        request: Text and optional audio to analyze
        target_id: Optional ID of the target entity (message, etc.)
        target_type: Type of target entity
        current_user: Authenticated user information
        
    Returns:
        Generated feedback
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Generate feedback using the audio processor utility
        feedback_data, pronunciation_data = generate_feedback(
            user_text=request.text,
            reference_text=request.reference_text
        )
        
        # Prepare feedback model
        if target_id:
            target_object_id = ObjectId(target_id)
        else:
            # If no target_id is provided, create a standalone feedback
            target_object_id = ObjectId()
            
        feedback_model = Feedback(
            target_id=target_object_id,
            target_type=target_type,
            grammar_issues=feedback_data.get("grammar", []),
            vocabulary_suggestions=feedback_data.get("vocabulary", []),
            pronunciation_feedback=pronunciation_data,
            fluency_score=None,  # We'll calculate this in the future
            positive_aspects=feedback_data.get("positives", []),
            prioritized_improvements=feedback_data.get("fluency", [])
        )
        
        # Insert feedback into database
        result = db.feedback.insert_one(feedback_model.to_dict())
        created_feedback = db.feedback.find_one({"_id": result.inserted_id})
        
        # Update the target entity with feedback ID if it exists
        if target_type == "message" and target_id:
            db.messages.update_one(
                {"_id": target_object_id},
                {"$set": {"feedback": str(result.inserted_id)}}
            )
        elif target_type == "audio" and target_id:
            db.audio.update_one(
                {"_id": target_object_id},
                {"$set": {"feedback": str(result.inserted_id)}}
            )
        
        # Create mistake records from feedback
        mistakes = feedback_model.export_to_mistakes()
        for mistake_data in mistakes:
            mistake = Mistake(
                user_id=user_id,
                type=mistake_data["type"],
                original_content=mistake_data["original_content"],
                correction=mistake_data["correction"],
                explanation=mistake_data["explanation"],
                context=mistake_data["context"]
            )
            db.mistakes.insert_one(mistake.to_dict())
        
        # Convert ObjectIds to strings for response
        created_feedback["_id"] = str(created_feedback["_id"])
        created_feedback["target_id"] = str(created_feedback["target_id"])
        
        return FeedbackResponse(**created_feedback)
    
    except Exception as e:
        raise handle_general_exception(e, "feedback generation")


@router.get("/history", response_model=List[FeedbackResponse])
async def get_feedback_history(
    limit: int = 20,
    skip: int = 0,
    target_type: Optional[str] = None,
    current_user: dict = Depends(get_current_user)
):
    """
    Get the user's feedback history.
    
    Args:
        limit: Maximum number of records to return
        skip: Number of records to skip for pagination
        target_type: Optional filter by target type
        current_user: Authenticated user information
        
    Returns:
        List of feedback records
    """
    try:
        # Get messages for the user
        query = {}
        
        # If target_type is specified, filter by it
        if target_type:
            query["target_type"] = target_type
            
        # Get associated feedback
        cursor = db.feedback.find(query)
        
        # Apply pagination
        cursor = cursor.sort("created_at", -1).skip(skip).limit(limit)
        
        # Convert to list and format ObjectIds
        result = []
        for feedback in cursor:
            feedback["_id"] = str(feedback["_id"])
            feedback["target_id"] = str(feedback["target_id"])
            result.append(FeedbackResponse(**feedback))
        
        return result
    
    except Exception as e:
        raise handle_general_exception(e, "feedback history")


@router.get("/{feedback_id}", response_model=FeedbackResponse)
async def get_feedback(
    feedback_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Get a specific feedback record by ID.
    
    Args:
        feedback_id: ID of the feedback record
        current_user: Authenticated user information
        
    Returns:
        The feedback record
    """
    try:
        # Get the feedback record
        feedback = db.feedback.find_one({"_id": ObjectId(feedback_id)})
        
        if not feedback:
            raise get_not_found_exception("Feedback", feedback_id)
        
        # Format ObjectIds
        feedback["_id"] = str(feedback["_id"])
        feedback["target_id"] = str(feedback["target_id"])
        
        return FeedbackResponse(**feedback)
    
    except ValueError:
        raise get_not_found_exception("Feedback", feedback_id)
    except Exception as e:
        raise handle_general_exception(e, "feedback")


@router.get("/for/{target_type}/{target_id}", response_model=FeedbackResponse)
async def get_feedback_for_target(
    target_type: str,
    target_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Get feedback for a specific target entity.
    
    Args:
        target_type: Type of target entity ("message", "audio", etc.)
        target_id: ID of the target entity
        current_user: Authenticated user information
        
    Returns:
        The feedback record for the target
    """
    try:
        # Get the feedback record
        feedback = db.feedback.find_one({
            "target_id": ObjectId(target_id),
            "target_type": target_type
        })
        
        if not feedback:
            raise get_not_found_exception(f"Feedback for {target_type}", target_id)
        
        # Format ObjectIds
        feedback["_id"] = str(feedback["_id"])
        feedback["target_id"] = str(feedback["target_id"])
        
        return FeedbackResponse(**feedback)
    
    except ValueError:
        raise get_not_found_exception(f"Feedback for {target_type}", target_id)
    except Exception as e:
        raise handle_general_exception(e, "feedback")
