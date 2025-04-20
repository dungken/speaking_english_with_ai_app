from datetime import datetime, timedelta
from bson import ObjectId
from typing import Optional

class Mistake:
    """
    Model representing a language mistake made by a user.
    
    Attributes:
        _id: Unique identifier
        user_id: ID of the user who made the mistake
        type: Type of mistake (grammar, vocabulary, pronunciation, fluency)
        original_content: The original incorrect content
        correction: The corrected version
        explanation: Explanation of why it's a mistake and how to fix it
        frequency: Number of times this mistake has been made
        severity: How severe the mistake is (1-5)
        last_occurred: When this mistake was last made
        context: Original context where the mistake occurred
        in_drill_queue: Whether this mistake is queued for drilling
        next_practice_date: When this mistake should be practiced next
    """
    def __init__(
        self,
        user_id: ObjectId,
        type: str,  # "grammar", "vocabulary", "pronunciation", "fluency", "cultural_context"
        original_content: str,
        correction: str,
        explanation: str,
        context: str,
        severity: int = 3,  # 1-5, with 5 being most severe
    ):
        self._id = ObjectId()
        self.user_id = user_id
        self.type = type
        self.original_content = original_content
        self.correction = correction
        self.explanation = explanation
        self.frequency = 1
        self.severity = severity
        self.last_occurred = datetime.utcnow()
        self.context = context
        self.in_drill_queue = True
        self.next_practice_date = datetime.utcnow() + timedelta(days=1)  # Start drilling tomorrow
        self.created_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()
        self.is_learned = False
        self.successful_practices = 0
        self.failed_practices = 0

    def to_dict(self):
        """Convert the Mistake instance to a dictionary for MongoDB storage."""
        return {
            "_id": self._id,
            "user_id": self.user_id,
            "type": self.type,
            "original_content": self.original_content,
            "correction": self.correction,
            "explanation": self.explanation,
            "frequency": self.frequency,
            "severity": self.severity,
            "last_occurred": self.last_occurred,
            "context": self.context,
            "in_drill_queue": self.in_drill_queue,
            "next_practice_date": self.next_practice_date,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "is_learned": self.is_learned,
            "successful_practices": self.successful_practices,
            "failed_practices": self.failed_practices
        }
        
    def increment_frequency(self):
        """Increment the frequency counter when the mistake is repeated."""
        self.frequency += 1
        self.last_occurred = datetime.utcnow()
        self.updated_at = datetime.utcnow()
        
        # If the mistake was marked as learned, but occurs again, unmark it
        if self.is_learned:
            self.is_learned = False
            self.in_drill_queue = True
            
        # Update next practice date based on frequency
        # More frequent mistakes should be practiced sooner
        days_offset = max(1, 7 - min(self.frequency, 5))
        self.next_practice_date = datetime.utcnow() + timedelta(days=days_offset)
        
    def schedule_next_practice(self, performance_score: Optional[float] = None):
        """
        Schedule the next practice session based on performance and spaced repetition.
        
        Args:
            performance_score: Optional score from 0-1 indicating performance in practice
        """
        self.updated_at = datetime.utcnow()
        
        if performance_score is not None:
            if performance_score >= 0.8:  # Good performance
                self.successful_practices += 1
                # Increase interval with each successful practice
                interval_days = min(30, self.successful_practices * 2)
                self.next_practice_date = datetime.utcnow() + timedelta(days=interval_days)
                
                # Mark as learned if consistently successful
                if self.successful_practices >= 3:
                    self.is_learned = True
                    self.in_drill_queue = False
            else:  # Poor performance
                self.failed_practices += 1
                # Short interval for another practice
                self.next_practice_date = datetime.utcnow() + timedelta(days=1)
                self.is_learned = False
                self.in_drill_queue = True
        else:
            # Default scheduling if no performance provided
            self.next_practice_date = datetime.utcnow() + timedelta(days=3)
            
    def calculate_priority(self) -> float:
        """
        Calculate the priority score for this mistake for practice ordering.
        
        Returns:
            Priority score (higher means higher priority)
        """
        # Base priority factors:
        # 1. Frequency - more frequent mistakes are higher priority
        # 2. Severity - more severe mistakes are higher priority
        # 3. Recency - more recent mistakes are higher priority
        # 4. Failed practices - more failed attempts means higher priority
        
        frequency_factor = min(5, self.frequency) / 5  # 0.2 to 1.0
        severity_factor = self.severity / 5  # 0.2 to 1.0
        
        # Calculate days since last occurrence
        days_since = (datetime.utcnow() - self.last_occurred).days
        recency_factor = 1 / (1 + days_since * 0.1)  # Decreases with time
        
        # Failed practices factor
        failed_factor = min(1.0, self.failed_practices * 0.2)  # 0.0 to 1.0
        
        # Combined priority score (0.0 to 5.0)
        priority = (
            frequency_factor * 2.0 +  # 0.4 to 2.0
            severity_factor * 1.5 +   # 0.3 to 1.5
            recency_factor * 1.0 +    # 0.0 to 1.0
            failed_factor * 0.5       # 0.0 to 0.5
        )
        
        return priority
        
    def mark_as_learned(self):
        """Mark this mistake as learned and remove from drill queue."""
        self.is_learned = True
        self.in_drill_queue = False
        self.updated_at = datetime.utcnow()
