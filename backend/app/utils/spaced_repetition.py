"""
Spaced repetition algorithm for scheduling mistake practice sessions.

This module implements a modified version of the SuperMemo-2 algorithm
for spaced repetition learning, adapted for language mistake drilling.
"""

from datetime import datetime, timedelta
from typing import List, Dict, Any
import math
import logging

# Initialize logger
logger = logging.getLogger(__name__)

def calculate_next_review_time(
    previous_interval: int, 
    ease_factor: float,
    performance: float
) -> Dict[str, Any]:
    """
    Calculate the next review interval based on SM-2 algorithm.
    
    Args:
        previous_interval: Previous interval in days (0 for new items)
        ease_factor: Current ease factor (start with 2.5 for new items)
        performance: Performance rating from 0 to 1
    
    Returns:
        Dictionary with new interval in days and new ease factor
    """
    # Convert performance from 0-1 scale to 0-5 scale for SM-2
    performance_sm2 = performance * 5
    
    # If performance is very poor, reset to day 1
    if performance_sm2 < 2:
        return {
            "interval": 1,
            "ease_factor": max(1.3, ease_factor - 0.2)
        }
        
    # For first-time items
    if previous_interval == 0:
        return {
            "interval": 1,
            "ease_factor": ease_factor
        }
    
    # For items with interval of 1
    elif previous_interval == 1:
        return {
            "interval": 6,
            "ease_factor": ease_factor
        }
        
    # For all other items
    else:
        # Adjust ease factor based on performance
        new_ease_factor = ease_factor + (0.1 - (5 - performance_sm2) * 0.08)
        new_ease_factor = max(1.3, new_ease_factor)
        
        # Calculate new interval
        new_interval = math.ceil(previous_interval * new_ease_factor)
        
        # Cap maximum interval at 30 days
        new_interval = min(30, new_interval)
        
        return {
            "interval": new_interval,
            "ease_factor": new_ease_factor
        }


def prioritize_mistakes_for_review(mistakes: List[Dict[str, Any]], limit: int = 10) -> List[Dict[str, Any]]:
    """
    Sort and prioritize mistakes for review based on various factors.
    
    Args:
        mistakes: List of mistake dictionaries
        limit: Maximum number of mistakes to return
    
    Returns:
        Sorted list of mistakes for review, limited to specified count
    """
    try:
        # Score each mistake based on prioritization factors
        for mistake in mistakes:
            # Skip mistakes not in drill queue
            if not mistake.get("in_drill_queue", True):
                mistake["priority_score"] = -1
                continue
                
            # Calculate base priority score
            frequency = min(5, mistake.get("frequency", 1))
            severity = mistake.get("severity", 3)
            
            # Calculate days since last occurrence
            last_occurred = mistake.get("last_occurred", datetime.utcnow())
            if isinstance(last_occurred, str):
                last_occurred = datetime.fromisoformat(last_occurred.replace("Z", "+00:00"))
            days_since = (datetime.utcnow() - last_occurred).days
            
            # More recent mistakes get higher priority, but with diminishing returns
            recency_factor = 1 / (1 + days_since * 0.1)
            
            # Failed practices increase priority
            failed_practices = mistake.get("failed_practices", 0)
            failed_factor = min(1.0, failed_practices * 0.2)
            
            # Due date factor - higher priority for overdue items
            next_practice = mistake.get("next_practice_date", datetime.utcnow())
            if isinstance(next_practice, str):
                next_practice = datetime.fromisoformat(next_practice.replace("Z", "+00:00"))
            
            days_overdue = (datetime.utcnow() - next_practice).days
            due_factor = 1.0
            if days_overdue > 0:
                due_factor = 1.0 + min(1.0, days_overdue * 0.1)
            elif days_overdue < 0:  # Not due yet
                due_factor = max(0.1, 1.0 + days_overdue * 0.1)
            
            # Combined priority score
            priority = (
                frequency * 2.0 +      # 2-10 points for frequency
                severity * 1.5 +       # 1.5-7.5 points for severity
                recency_factor * 5.0 + # 0-5 points for recency
                failed_factor * 3.0 +  # 0-3 points for failed practices
                due_factor * 5.0       # 0.5-10 points for due date
            )
            
            mistake["priority_score"] = priority
        
        # Filter out mistakes not in drill queue
        active_mistakes = [m for m in mistakes if m.get("priority_score", -1) >= 0]
        
        # Sort by priority score (descending)
        sorted_mistakes = sorted(active_mistakes, key=lambda x: x.get("priority_score", 0), reverse=True)
        
        # Limit to specified count
        return sorted_mistakes[:limit]
    
    except Exception as e:
        logger.error(f"Error prioritizing mistakes: {str(e)}")
        # Fall back to simple sorting by frequency if there's an error
        return sorted(mistakes, key=lambda x: x.get("frequency", 0), reverse=True)[:limit]


def get_review_session(mistakes: List[Dict[str, Any]], user_id: str, session_size: int = 5) -> Dict[str, Any]:
    """
    Create a review session for the given user.
    
    Args:
        mistakes: List of all user mistakes
        user_id: User ID
        session_size: Maximum number of mistakes in the session
        
    Returns:
        Dictionary with session information and mistakes to review
    """
    # Prioritize mistakes for review
    prioritized_mistakes = prioritize_mistakes_for_review(mistakes, limit=session_size)
    
    # Create session
    session = {
        "session_id": f"session_{datetime.utcnow().strftime('%Y%m%d%H%M%S')}",
        "user_id": user_id,
        "mistakes": prioritized_mistakes,
        "created_at": datetime.utcnow(),
        "expires_at": datetime.utcnow() + timedelta(hours=24)
    }
    
    return session


def record_review_result(
    mistake: Dict[str, Any], 
    performance: float
) -> Dict[str, Any]:
    """
    Update mistake scheduling based on review performance.
    
    Args:
        mistake: Mistake dictionary
        performance: Performance score (0-1)
        
    Returns:
        Updated mistake dictionary
    """
    # Get current values
    current_interval = 0
    if "next_practice_date" in mistake and "last_occurred" in mistake:
        next_date = mistake["next_practice_date"]
        last_date = mistake["last_occurred"]
        
        if isinstance(next_date, str):
            next_date = datetime.fromisoformat(next_date.replace("Z", "+00:00"))
        if isinstance(last_date, str):
            last_date = datetime.fromisoformat(last_date.replace("Z", "+00:00"))
            
        current_interval = (next_date - last_date).days
    
    # Default ease factor if not present
    ease_factor = mistake.get("ease_factor", 2.5)
    
    # Calculate next review using SM-2
    next_review = calculate_next_review_time(current_interval, ease_factor, performance)
    
    # Update mistake
    mistake["ease_factor"] = next_review["ease_factor"]
    mistake["next_practice_date"] = datetime.utcnow() + timedelta(days=next_review["interval"])
    
    # Update practice counters
    if performance >= 0.8:  # Success threshold
        mistake["successful_practices"] = mistake.get("successful_practices", 0) + 1
        
        # Mark as learned after 3 successful practices
        if mistake.get("successful_practices", 0) >= 3:
            mistake["is_learned"] = True
            mistake["in_drill_queue"] = False
    else:
        mistake["failed_practices"] = mistake.get("failed_practices", 0) + 1
        mistake["is_learned"] = False
        mistake["in_drill_queue"] = True
    
    mistake["last_review_date"] = datetime.utcnow()
    mistake["updated_at"] = datetime.utcnow()
    
    return mistake
