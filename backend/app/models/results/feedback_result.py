from datetime import datetime
from typing import Dict, Any, Optional, List, Union

class DetailedFeedback:
    """
    Model representing detailed structured feedback on language issues.
    
    Attributes:
        grammar_issues: List of grammar issues detected
        vocabulary_issues: List of vocabulary improvements suggested
    """
    def __init__(
        self,
        grammar_issues: Optional[List[Dict[str, Any]]] = None,
        vocabulary_issues: Optional[List[Dict[str, Any]]] = None
    ):
        self.grammar_issues = grammar_issues or []
        self.vocabulary_issues = vocabulary_issues or []
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for storage"""
        return {
            "grammar_issues": self.grammar_issues,
            "vocabulary_issues": self.vocabulary_issues
        }
        
    def extract_mistakes(self) -> List[Dict[str, Any]]:
        """
        Extract mistakes from the detailed feedback.
        
        Returns:
            List of mistakes for tracking and drilling
        """
        mistakes = []
        
        # Convert grammar issues to mistakes
        for issue in self.grammar_issues:
            mistakes.append({
                "type": "GRAMMAR",
                "original_text": issue.get("issue", ""),
                "correction": issue.get("correction", ""),
                "explanation": issue.get("explanation", ""),
                "context": "Grammar issue from feedback",
                "severity": issue.get("severity", 3)
            })
            
        # Convert vocabulary issues to mistakes
        for issue in self.vocabulary_issues:
            mistakes.append({
                "type": "VOCABULARY",
                "original_text": issue.get("original", ""),
                "correction": issue.get("better_alternative", ""),
                "explanation": issue.get("reason", ""),
                "context": issue.get("example_usage", ""),
                "severity": 3
            })
                    
        return mistakes

class FeedbackResult:
    """
    Result of feedback generation, as defined in class diagram.
    
    Attributes:
        user_feedback: User-friendly text feedback
        detailed_feedback: Structured detailed feedback
        timestamp: Timestamp when feedback was generated
    """
    def __init__(
        self,
        user_feedback: str,
        detailed_feedback: Union[DetailedFeedback, Dict[str, Any]],
        timestamp: Optional[datetime] = None
    ):
        self.user_feedback = user_feedback
        
        # Handle detailed_feedback as either a DetailedFeedback object or a dictionary
        if isinstance(detailed_feedback, DetailedFeedback):
            self.detailed_feedback = detailed_feedback
        else:
            grammar_issues = detailed_feedback.get("grammar_issues", [])
            vocabulary_issues = detailed_feedback.get("vocabulary_issues", [])
            self.detailed_feedback = DetailedFeedback(grammar_issues, vocabulary_issues)
            
        self.timestamp = timestamp or datetime.utcnow()
    
    def generate_user_friendly_text(self) -> str:
        """Generate user-friendly text from feedback"""
        return self.user_feedback
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for storage"""
        return {
            "user_feedback": self.user_feedback,
            "detailed_feedback": self.detailed_feedback.to_dict(),
            "timestamp": self.timestamp
        } 