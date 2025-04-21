from fastapi import APIRouter, Depends, HTTPException, status, Query, Body
from bson import ObjectId
from typing import List, Optional, Dict, Any
from datetime import datetime

from app.config.database import db
from app.models.mistake import Mistake
from app.schemas.mistake import MistakeCreate, MistakeResponse, MistakePracticeResult, MistakeDrillSession, MistakeUpdate
from app.utils.auth import get_current_user
from app.utils.spaced_repetition import get_review_session, record_review_result
from app.utils.error_handler import get_not_found_exception, handle_general_exception
from app.utils.mistake_service import MistakeService, MistakeStatistics

router = APIRouter()

# Initialize services
mistake_service = MistakeService()

@router.post("/create", response_model=MistakeResponse)
async def create_mistake(
    mistake: MistakeCreate,
    current_user: dict = Depends(get_current_user)
):
    """
    Create a new mistake record manually.
    
    Args:
        mistake: Mistake data to create
        current_user: Authenticated user information
        
    Returns:
        The created mistake record
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Create mistake model
        mistake_model = Mistake(
            user_id=user_id,
            type=mistake.type,
            original_content=mistake.original_content,
            correction=mistake.correction,
            explanation=mistake.explanation,
            context=mistake.context,
            severity=mistake.severity
        )
        
        # Insert into database
        result = db.mistakes.insert_one(mistake_model.to_dict())
        
        # Fetch the inserted record
        created_mistake = db.mistakes.find_one({"_id": result.inserted_id})
        
        # Convert ObjectIds to strings
        created_mistake["_id"] = str(created_mistake["_id"])
        created_mistake["user_id"] = str(created_mistake["user_id"])
        
        return MistakeResponse(**created_mistake)
    
    except Exception as e:
        raise handle_general_exception(e, "mistake creation")


@router.get("/list", response_model=List[MistakeResponse])
async def list_mistakes(
    type: Optional[str] = None,
    in_drill_queue: Optional[bool] = None,
    is_learned: Optional[bool] = None,
    limit: int = Query(50, ge=1, le=100),
    skip: int = Query(0, ge=0),
    current_user: dict = Depends(get_current_user)
):
    """
    List mistakes for the current user with optional filtering.
    
    Args:
        type: Optional filter by mistake type
        in_drill_queue: Optional filter by drill queue status
        is_learned: Optional filter by learned status
        limit: Maximum number of records to return
        skip: Number of records to skip for pagination
        current_user: Authenticated user information
        
    Returns:
        List of mistake records
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Base query for user's mistakes
        query = {"user_id": user_id}
        
        # Add filters if provided
        if type is not None:
            query["type"] = type
        if in_drill_queue is not None:
            query["in_drill_queue"] = in_drill_queue
        if is_learned is not None:
            query["is_learned"] = is_learned
        
        # Fetch mistakes
        cursor = db.mistakes.find(query).sort("created_at", -1).skip(skip).limit(limit)
        
        # Convert to list and format ObjectIds
        result = []
        for mistake in cursor:
            mistake["_id"] = str(mistake["_id"])
            mistake["user_id"] = str(mistake["user_id"])
            result.append(MistakeResponse(**mistake))
        
        return result
    
    except Exception as e:
        raise handle_general_exception(e, "mistake listing")


@router.get("/drill-session", response_model=MistakeDrillSession)
async def get_drill_session(
    session_size: int = Query(5, ge=1, le=20),
    current_user: dict = Depends(get_current_user)
):
    """
    Get a personalized drill session with mistakes to practice.
    
    Args:
        session_size: Number of mistakes to include in the session
        current_user: Authenticated user information
        
    Returns:
        Drill session with mistakes to practice
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Find all active mistakes for the user
        query = {
            "user_id": user_id,
            "in_drill_queue": True,
            "next_practice_date": {"$lte": datetime.utcnow()}
        }
        
        # Fetch mistakes
        mistakes = list(db.mistakes.find(query))
        
        # Convert mistakes for the review session function
        mistakes_dicts = []
        for mistake in mistakes:
            mistake_dict = mistake.copy()
            mistake_dict["_id"] = str(mistake_dict["_id"])
            mistake_dict["user_id"] = str(mistake_dict["user_id"])
            mistakes_dicts.append(mistake_dict)
        
        # Generate a review session
        session = get_review_session(
            mistakes=mistakes_dicts,
            user_id=str(user_id),
            session_size=session_size
        )
        
        # Convert to response model
        return MistakeDrillSession(
            mistakes=[MistakeResponse(**mistake) for mistake in session["mistakes"]],
            session_id=session["session_id"],
            created_at=session["created_at"]
        )
    
    except Exception as e:
        raise handle_general_exception(e, "drill session creation")


@router.post("/practice-result", response_model=MistakeResponse)
async def submit_practice_result(
    result: MistakePracticeResult,
    current_user: dict = Depends(get_current_user)
):
    """
    Submit practice result for a mistake.
    
    Args:
        result: Practice result data
        current_user: Authenticated user information
        
    Returns:
        Updated mistake record
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Get the mistake
        mistake = db.mistakes.find_one({
            "_id": ObjectId(result.mistake_id),
            "user_id": user_id
        })
        
        if not mistake:
            raise get_not_found_exception("Mistake", result.mistake_id)
        
        # Record the practice result
        updated_mistake = record_review_result(
            mistake=mistake,
            performance=result.performance_score
        )
        
        # Update in database
        db.mistakes.update_one(
            {"_id": mistake["_id"]},
            {"$set": {
                "next_practice_date": updated_mistake["next_practice_date"],
                "ease_factor": updated_mistake.get("ease_factor", 2.5),
                "successful_practices": updated_mistake["successful_practices"],
                "failed_practices": updated_mistake["failed_practices"],
                "is_learned": updated_mistake["is_learned"],
                "in_drill_queue": updated_mistake["in_drill_queue"],
                "last_review_date": updated_mistake["last_review_date"],
                "updated_at": updated_mistake["updated_at"]
            }}
        )
        
        # Fetch updated mistake
        updated_mistake_doc = db.mistakes.find_one({"_id": mistake["_id"]})
        
        # Convert ObjectIds to strings
        updated_mistake_doc["_id"] = str(updated_mistake_doc["_id"])
        updated_mistake_doc["user_id"] = str(updated_mistake_doc["user_id"])
        
        return MistakeResponse(**updated_mistake_doc)
    
    except ValueError:
        raise get_not_found_exception("Mistake", result.mistake_id)
    except Exception as e:
        raise handle_general_exception(e, "practice result submission")


@router.get("/{mistake_id}", response_model=MistakeResponse)
async def get_mistake(
    mistake_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Get a specific mistake by ID.
    
    Args:
        mistake_id: ID of the mistake
        current_user: Authenticated user information
        
    Returns:
        The mistake record
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Get the mistake
        mistake = db.mistakes.find_one({
            "_id": ObjectId(mistake_id),
            "user_id": user_id
        })
        
        if not mistake:
            raise get_not_found_exception("Mistake", mistake_id)
        
        # Convert ObjectIds to strings
        mistake["_id"] = str(mistake["_id"])
        mistake["user_id"] = str(mistake["user_id"])
        
        return MistakeResponse(**mistake)
    
    except ValueError:
        raise get_not_found_exception("Mistake", mistake_id)
    except Exception as e:
        raise handle_general_exception(e, "mistake retrieval")


@router.patch("/{mistake_id}", response_model=MistakeResponse)
async def update_mistake(
    mistake_id: str,
    update_data: MistakeUpdate,
    current_user: dict = Depends(get_current_user)
):
    """
    Update a mistake record.
    
    Args:
        mistake_id: ID of the mistake to update
        update_data: Data to update
        current_user: Authenticated user information
        
    Returns:
        The updated mistake record
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Get the mistake
        mistake = db.mistakes.find_one({
            "_id": ObjectId(mistake_id),
            "user_id": user_id
        })
        
        if not mistake:
            raise get_not_found_exception("Mistake", mistake_id)
        
        # Prepare update data
        update_dict = update_data.dict(exclude_unset=True)
        if update_dict:
            update_dict["updated_at"] = datetime.utcnow()
            
            # Update in database
            db.mistakes.update_one(
                {"_id": mistake["_id"]},
                {"$set": update_dict}
            )
        
        # Fetch updated mistake
        updated_mistake = db.mistakes.find_one({"_id": mistake["_id"]})
        
        # Convert ObjectIds to strings
        updated_mistake["_id"] = str(updated_mistake["_id"])
        updated_mistake["user_id"] = str(updated_mistake["user_id"])
        
        return MistakeResponse(**updated_mistake)
    
    except ValueError:
        raise get_not_found_exception("Mistake", mistake_id)
    except Exception as e:
        raise handle_general_exception(e, "mistake update")


@router.delete("/{mistake_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_mistake(
    mistake_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Delete a mistake record.
    
    Args:
        mistake_id: ID of the mistake to delete
        current_user: Authenticated user information
        
    Returns:
        204 No Content
    """
    try:
        user_id = ObjectId(current_user["_id"])
        
        # Delete the mistake
        result = db.mistakes.delete_one({
            "_id": ObjectId(mistake_id),
            "user_id": user_id
        })
        
        if result.deleted_count == 0:
            raise get_not_found_exception("Mistake", mistake_id)
        
        return None
    
    except ValueError:
        raise get_not_found_exception("Mistake", mistake_id)
    except Exception as e:
        raise handle_general_exception(e, "mistake deletion")


@router.get("/practice", response_model=List[Dict[str, Any]])
async def get_practice_items(
    limit: int = 5,
    current_user: dict = Depends(get_current_user)
):
    """
    Get mistakes ready for practice, ordered by priority.
    
    This endpoint matches the class diagram's getMistakesForPractice method.
    
    Args:
        limit: Maximum number of mistakes to return
        current_user: Authenticated user information
        
    Returns:
        List of practice items
    """
    try:
        user_id = str(current_user["_id"])
        return mistake_service.get_mistakes_for_practice(user_id, limit)
    except Exception as e:
        raise handle_general_exception(e, "retrieving practice items")

@router.post("/practice/{mistake_id}", response_model=Dict[str, Any])
async def record_practice_result(
    mistake_id: str,
    was_successful: bool = Body(..., embed=True),
    user_answer: str = Body(..., embed=True),
    current_user: dict = Depends(get_current_user)
):
    """
    Record the result of a practice attempt.
    
    This endpoint uses the class diagram's updateAfterPractice method.
    
    Args:
        mistake_id: ID of the practiced mistake
        was_successful: Whether the practice was successful
        user_answer: The user's answer during practice
        current_user: Authenticated user information
        
    Returns:
        Updated mistake information with feedback
    """
    try:
        user_id = str(current_user["_id"])
        
        # Create a result object to match the method signature
        result = {
            "user_id": user_id,
            "was_successful": was_successful,
            "user_answer": user_answer
        }
        
        # Update mistake after practice
        return mistake_service.update_after_practice(mistake_id, result)
    except Exception as e:
        raise handle_general_exception(e, "recording practice result")

@router.get("/statistics", response_model=Dict[str, Any])
async def get_mistake_statistics(
    current_user: dict = Depends(get_current_user)
):
    """
    Get statistics about the user's mistakes.
    
    This endpoint matches the class diagram's getMistakeStatistics method.
    
    Args:
        current_user: Authenticated user information
        
    Returns:
        Dictionary with statistics about the user's mistakes
    """
    try:
        user_id = str(current_user["_id"])
        statistics = mistake_service.get_mistake_statistics(user_id)
        return statistics.to_dict()
    except Exception as e:
        raise handle_general_exception(e, "retrieving mistake statistics")

@router.post("/sessions", response_model=Dict[str, Any])
async def create_practice_session(
    mistake_ids: List[str] = Body(..., embed=True),
    current_user: dict = Depends(get_current_user)
):
    """
    Create a new practice session with selected mistakes.
    
    This endpoint matches the class diagram's createPracticeSession method.
    
    Args:
        mistake_ids: List of mistake IDs to include in the session
        current_user: Authenticated user information
        
    Returns:
        Created practice session
    """
    try:
        user_id = str(current_user["_id"])
        
        # Get the selected mistakes
        mistakes = []
        for mistake_id in mistake_ids:
            mistake = db.mistakes.find_one({
                "_id": ObjectId(mistake_id),
                "user_id": ObjectId(user_id)
            })
            if mistake:
                mistakes.append(mistake)
        
        # Create the practice session
        return mistake_service.create_practice_session(user_id, mistakes)
    except Exception as e:
        raise handle_general_exception(e, "creating practice session")

@router.get("/", response_model=List[Dict[str, Any]])
async def get_unmastered_mistakes(
    current_user: dict = Depends(get_current_user)
):
    """
    Get all unmastered mistakes for the user.
    
    This endpoint matches the class diagram's getUnmasteredMistakes method.
    
    Args:
        current_user: Authenticated user information
        
    Returns:
        List of unmastered mistakes
    """
    try:
        user_id = str(current_user["_id"])
        return mistake_service.get_unmastered_mistakes(user_id)
    except Exception as e:
        raise handle_general_exception(e, "retrieving unmastered mistakes")
