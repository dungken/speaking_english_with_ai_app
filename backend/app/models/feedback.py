from datetime import datetime
from bson import ObjectId
from typing import Dict, List, Any, Optional

class Feedback:
    """
    Model representing feedback for a user's language performance.
    
    Attributes:
        _id: Unique identifier
        target_id: ID of the entity receiving feedback (message, audio, etc.)
        target_type: Type of entity receiving feedback ("message", "audio", etc.)
        grammar_issues: List of grammar issues detected
        vocabulary_suggestions: List of vocabulary improvement suggestions
        pronunciation_feedback: Pronunciation feedback (if applicable)
        fluency_score: Score for fluency/natural expression (0-100)
        positive_aspects: List of positive aspects in the user's performance
        prioritized_improvements: List of most important improvements to focus on
    """
    def __init__(
        self,
        target_id: ObjectId,
        target_type: str,  # "message", "audio", "image_description"
        grammar_issues: Optional[List[Dict[str, str]]] = None,
        vocabulary_suggestions: Optional[List[Dict[str, str]]] = None,
        pronunciation_feedback: Optional[Dict[str, Any]] = None,
        fluency_score: Optional[float] = None,
        positive_aspects: Optional[List[str]] = None,
        prioritized_improvements: Optional[List[str]] = None
    ):
        self._id = ObjectId()
        self.target_id = target_id
        self.target_type = target_type
        self.grammar_issues = grammar_issues or []
        self.vocabulary_suggestions = vocabulary_suggestions or []
        self.pronunciation_feedback = pronunciation_feedback
        self.fluency_score = fluency_score
        self.positive_aspects = positive_aspects or []
        self.prioritized_improvements = prioritized_improvements or []
        self.created_at = datetime.utcnow()

    def to_dict(self):
        """Convert the Feedback instance to a dictionary for MongoDB storage."""
        return {
            "_id": self._id,
            "target_id": self.target_id,
            "target_type": self.target_type,
            "grammar_issues": self.grammar_issues,
            "vocabulary_suggestions": self.vocabulary_suggestions,
            "pronunciation_feedback": self.pronunciation_feedback,
            "fluency_score": self.fluency_score,
            "positive_aspects": self.positive_aspects,
            "prioritized_improvements": self.prioritized_improvements,
            "created_at": self.created_at
        }
        
    def export_to_mistakes(self) -> List[Dict[str, Any]]:
        """
        Export feedback to mistake format for mistake tracking.
        
        Returns:
            List of mistakes for tracking and drilling
        """
        mistakes = []
        
        # Convert grammar issues to mistakes
        for issue in self.grammar_issues:
            mistakes.append({
                "type": "grammar",
                "original_content": issue.get("issue", ""),
                "correction": issue.get("correction", ""),
                "explanation": issue.get("explanation", ""),
                "context": "Grammar issue from feedback"
            })
            
        # Convert vocabulary suggestions to mistakes
        for suggestion in self.vocabulary_suggestions:
            mistakes.append({
                "type": "vocabulary",
                "original_content": suggestion.get("original", ""),
                "correction": suggestion.get("suggestion", ""),
                "explanation": suggestion.get("context", ""),
                "context": "Vocabulary improvement from feedback"
            })
            
        # Convert pronunciation issues if available
        if self.pronunciation_feedback and "word_scores" in self.pronunciation_feedback:
            for word, score in self.pronunciation_feedback["word_scores"].items():
                if score < 70:  # Only track words with low scores
                    mistakes.append({
                        "type": "pronunciation",
                        "original_content": word,
                        "correction": word,  # Same word, but properly pronounced
                        "explanation": f"Pronunciation score: {score}/100",
                        "context": "Pronunciation issue from feedback"
                    })
                    
        return mistakes
