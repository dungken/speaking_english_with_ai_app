"""
Audio processing utilities for transcription using local speech recognition.

This module provides functionality for:
1. Audio file transcription using local speech recognition
2. Basic audio file operations
3. AI-powered language feedback generation
"""

import os
import json
import tempfile
import logging
import time
from pathlib import Path
from typing import Dict, Any, Optional, Tuple, List
from dotenv import load_dotenv
import google.generativeai as genai
from datetime import datetime
from bson import ObjectId
import logging
import whisper
import torch
from threading import Lock

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()





genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
gemini_model = genai.GenerativeModel("gemini-1.5-flash")

# Initialize logger
logger = logging.getLogger(__name__)
class ModelPool:
    def __init__(self, max_models=3):
        self.model_size = "tiny"
        self.models = {}
        self.last_used = {}
        self.max_models = max_models
        self.lock = Lock()
  
    def get_model(self):
        
        # Map 'turbo' to 'large-v3-turbo' for consistency with newer releases
        device = self.get_device()
        
        if device == "cuda":
            self.model_size = "large-v3-turbo"
        else:
            self.model_size = "tiny"
            
     
    
        key = f"{self.model_size}_{device}"
        
        if key in self.models:
            self.last_used[key] = time.time()
            return self.models[key]
        logger.info(f"Loading Whisper {self.model_size} model on {device}...")
        
        model = whisper.load_model(self.model_size, device=device)
            
        
        # Remove oldest model if pool is full
        if len(self.models) >= self.max_models:
            oldest_key = min(self.last_used.items(), key=lambda x: x[1])[0]
            del self.models[oldest_key]
            del self.last_used[oldest_key]
        
        self.models[key] = model
        self.last_used[key] = time.time()
        
        return model
    def get_device(self):
        cuda_available = torch.cuda.is_available()
        
        if cuda_available:
            device = "cuda"
            logger.info(f"GPU device: {torch.cuda.get_device_name(0)}")
            
        else:
            device = "cpu"
            
        return device


model = ModelPool(max_models=2)

loaded_model = model.get_model()


def transcribe_audio_local(audio_file_path: Path, language_code: str = "en-US"):
    """
    Transcribe audio using local SpeechRecognition library.
    
    This function converts spoken words in an audio file into text using Google's
    Web Speech API through the SpeechRecognition library. It handles various exceptions
    that may occur during the transcription process.
    
    Args:
        audio_file_path: Path to the audio file
        language_code: Language code (default: en-US)
        
    Returns:
        Dict with transcription text and confidence
    """
    try:
        import speech_recognition as sr
        
        # Initialize recognizer
        r = sr.Recognizer()
        
        # Load audio file
        with sr.AudioFile(audio_file_path.name) as source:
            # Read the audio data
            audio_data = r.record(source)
            
            # Recognize speech using Google Web Speech API (free)
            # You could also use other recognizers like Sphinx for offline recognition
            text = r.recognize_google(audio_data, language=language_code)
            
            return text
    
    except ImportError:
        logger.error("SpeechRecognition library not installed. Please install it with: pip install SpeechRecognition")
    except sr.UnknownValueError:
        logger.error("Speech recognition could not understand audio")

    except sr.RequestError as e:
        logger.error(f"Could not request results from Google Web Speech API; {str(e)}")
    except Exception as e:
        logger.error(f"Error in local transcription: {str(e)}")
    return text

def transcribe_audio_with_whisper(audio_file_path: Path, language_code: str = "en-US"):
    """
    Transcribe audio using Whisper model.
    This function uses the Whisper model to transcribe spoken words in an audio file into text.
    It handles various exceptions that may occur during the transcription process.
    """
    try:
        logger.info(f"Model used: {model.model_size}")
       
        if 'us' in language_code.lower():
            language_code = "en"
        else:
            language_code = "vi"
            
        transcribe_options = {
        "language": language_code,
        "task": "transcribe",
        }
        result = loaded_model.transcribe(str(audio_file_path), language=language_code)
        return result["text"]
    except Exception as e:
        logger.error(f"Error in local transcription: {str(e)}")
        return None
    
    
 
    
    
def generate_feedback(user_text: str, reference_text: Optional[str] = None) -> Tuple[Dict[str, Any], None]:
    """
    Generate language feedback for a piece of text.
    
    This function uses Google's Gemini AI to analyze spoken language and provide
    detailed feedback on grammar, vocabulary, positive aspects, and fluency suggestions.
    It handles error cases gracefully by providing fallback feedback options when
    the AI generation process encounters issues.
    
    Args:
        user_text: The text to analyze
        reference_text: Optional reference text to compare against
        
    Returns:
        Tuple of (language_feedback, None) where language_feedback contains grammar and vocabulary analysis
    """
    prompt = f"""
    You are an expert English teacher providing feedback on a student's speech.
    
    Student's text: "{user_text}"
    
    Analyze the text and provide feedback in JSON format with these fields:
    
    1. grammar: Array of grammar issues, where each issue has these properties:
       - issue: The exact problematic text
       - correction: How it should be corrected
       - explanation: Why this is an issue
       - severity: Number from 1-5 (1=minor, 5=major)
    
    2. vocabulary: Array of vocabulary improvement opportunities, where each has:
       - original: The word or phrase used
       - better_alternative: A better word or phrase
       - reason: Why the alternative is better
       - example_usage: An example sentence with the better alternative
    
    3. positives: Array of positive aspects of the student's language use
    
    4. fluency: Array of suggestions to improve overall fluency and natural expression
    
    Return ONLY the JSON object, properly formatted.
    """
    
    try:
        # Generate feedback using Gemini
        response = gemini_model.generate_content(prompt)
        response_text = response.text
        
        # Parse the JSON response
        try:
            feedback_data = json.loads(response_text)
            return feedback_data, None
        except json.JSONDecodeError:
            logger.error(f"Failed to parse Gemini response as JSON: {response_text}")
            return {
                "grammar": [],
                "vocabulary": [],
                "positives": ["Your response was clear."],
                "fluency": ["Continue practicing to improve your fluency."]
            }, None
            
    except Exception as e:
        logger.error(f"Error generating feedback: {str(e)}")
        return {
            "grammar": [],
            "vocabulary": [],
            "positives": ["Your response was recorded."],
            "fluency": ["Keep practicing to improve your English skills."]
        }, None
