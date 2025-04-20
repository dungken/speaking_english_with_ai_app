"""
Audio processing utilities for transcription and pronunciation assessment.

This module provides functionality for:
1. Audio file transcription
2. Pronunciation assessment and scoring
3. Generating pronunciation feedback
"""

import os
import json
import tempfile
import requests
import logging
from typing import Dict, Any, Optional, Tuple
from dotenv import load_dotenv
import google.generativeai as genai
import google.cloud.speech as speech

# Load environment variables
load_dotenv()

# Configure Google Generative AI
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
gemini_model = genai.GenerativeModel("gemini-1.5-flash")

# Initialize Google Cloud Speech client if API key is available
speech_client = None
if os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
    speech_client = speech.SpeechClient()

# Initialize logger
logger = logging.getLogger(__name__)

def transcribe_audio(audio_url: str, language_code: str = "en-US") -> Dict[str, Any]:
    """
    Transcribe audio file using Google Speech-to-Text API.
    
    Args:
        audio_url: URL to the audio file
        language_code: Language code for transcription (default: en-US)
        
    Returns:
        Dictionary containing transcription text and confidence
        
    Raises:
        ValueError: If transcription fails
    """
    try:
        # For demo purposes, we'll simulate transcription
        # In a real implementation, you would:
        # 1. Download the audio file from the URL
        # 2. Convert it to the required format
        # 3. Send it to the Speech-to-Text API
        
        if not speech_client:
            # For demo, return a mock response
            logger.warning("Speech client not initialized. Using mock transcription.")
            return {
                "text": "This is a mock transcription. Configure Google Cloud Speech for real transcription.",
                "confidence": 0.95
            }
            
        # Download the audio file from the URL
        response = requests.get(audio_url)
        
        if response.status_code != 200:
            raise ValueError(f"Failed to download audio file: {response.status_code}")
            
        # Save to a temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_file:
            temp_file.write(response.content)
            temp_file_path = temp_file.name
            
        try:
            # Read the audio file
            with open(temp_file_path, "rb") as audio_file:
                content = audio_file.read()
                
            audio = speech.RecognitionAudio(content=content)
            config = speech.RecognitionConfig(
                encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
                sample_rate_hertz=16000,
                language_code=language_code,
                enable_automatic_punctuation=True,
            )
            
            # Perform the transcription
            response = speech_client.recognize(config=config, audio=audio)
            
            # Process the response
            results = []
            confidence_sum = 0
            confidence_count = 0
            
            for result in response.results:
                results.append(result.alternatives[0].transcript)
                confidence_sum += result.alternatives[0].confidence
                confidence_count += 1
                
            text = " ".join(results)
            confidence = confidence_sum / confidence_count if confidence_count > 0 else 0
                
            return {
                "text": text,
                "confidence": confidence
            }
                
        finally:
            # Clean up the temporary file
            if os.path.exists(temp_file_path):
                os.remove(temp_file_path)
    
    except Exception as e:
        logger.error(f"Error transcribing audio: {str(e)}")
        raise ValueError(f"Transcription failed: {str(e)}")


def assess_pronunciation(audio_url: str, transcription: str, reference_text: Optional[str] = None) -> Dict[str, Any]:
    """
    Assess pronunciation quality of an audio recording.
    
    Args:
        audio_url: URL to the audio file
        transcription: Transcription of the audio
        reference_text: Optional reference text to compare against
        
    Returns:
        Dictionary containing pronunciation scores and feedback
    """
    try:
        # For demo purposes, we'll use Gemini to generate pronunciation feedback
        # In a real implementation, you would use a dedicated speech assessment API
        
        prompt = f"""
        I need to assess the pronunciation quality of an English learner based on their transcribed speech.
        
        The learner said: "{transcription}"
        
        {f'The correct text should be: "{reference_text}"' if reference_text else ''}
        
        Please provide a pronunciation assessment with the following:
        1. An overall score from 0-100
        2. A list of words that might be mispronounced
        3. 2-3 specific suggestions for improvement
        
        Format your response as a JSON object with the following structure:
        {{
            "overall_score": [score between 0-100],
            "word_scores": {{
                "word1": [score between 0-100],
                "word2": [score between 0-100],
                ...
            }},
            "improvement_suggestions": [
                "suggestion1",
                "suggestion2",
                ...
            ]
        }}
        """
        
        # Generate the assessment using Gemini
        response = gemini_model.generate_content(prompt)
        response_text = response.text
        
        # Extract JSON content if wrapped in markdown
        if "```json" in response_text:
            response_text = response_text.split("```json")[1].split("```")[0].strip()
        elif "```" in response_text:
            response_text = response_text.split("```")[1].split("```")[0].strip()
            
        # Parse the JSON response
        feedback = json.loads(response_text)
        
        return feedback
        
    except Exception as e:
        logger.error(f"Error assessing pronunciation: {str(e)}")
        # Return a basic assessment if the detailed one fails
        return {
            "overall_score": 70,  # Default middle score
            "word_scores": {},
            "improvement_suggestions": [
                "Practice speaking more clearly and slowly.",
                "Focus on proper enunciation of vowel sounds."
            ]
        }


def generate_feedback(user_text: str, reference_text: Optional[str] = None) -> Tuple[Dict[str, Any], Optional[Dict[str, Any]]]:
    """
    Generate language feedback for user's text.
    
    Args:
        user_text: Text provided by the user
        reference_text: Optional reference text to compare against
        
    Returns:
        Tuple containing:
          - Dictionary with grammar and vocabulary feedback
          - Dictionary with pronunciation suggestions (if audio available)
    """
    try:
        prompt = f"""
        As an English language tutor, I need to provide feedback on a learner's response.
        
        The learner said: "{user_text}"
        
        {f'The expected or model response would be: "{reference_text}"' if reference_text else ''}
        
        Please provide detailed feedback in the following categories:
        
        1. Grammar issues
        2. Vocabulary improvement suggestions
        3. Expression/Fluency feedback
        4. Positive aspects
        
        Format your response as a JSON object with the following structure:
        {{
            "grammar": [
                {{
                    "issue": "description of grammar issue",
                    "correction": "suggested correction",
                    "explanation": "explanation of the rule"
                }}
            ],
            "vocabulary": [
                {{
                    "original": "word or phrase used",
                    "suggestion": "better alternative",
                    "context": "why this is better in this context"
                }}
            ],
            "fluency": [
                "suggestion for improving natural flow"
            ],
            "positives": [
                "positive aspect of the response"
            ]
        }}
        """
        
        # Generate the feedback using Gemini
        response = gemini_model.generate_content(prompt)
        response_text = response.text
        
        # Extract JSON content if wrapped in markdown
        if "```json" in response_text:
            response_text = response_text.split("```json")[1].split("```")[0].strip()
        elif "```" in response_text:
            response_text = response_text.split("```")[1].split("```")[0].strip()
            
        # Parse the JSON response
        feedback = json.loads(response_text)
        
        # For now, return None for pronunciation as that would come from audio assessment
        return feedback, None
        
    except Exception as e:
        logger.error(f"Error generating feedback: {str(e)}")
        # Return basic feedback if detailed feedback generation fails
        return {
            "grammar": [],
            "vocabulary": [],
            "fluency": ["Practice more complex sentence structures."],
            "positives": ["Good attempt at expressing your thoughts."]
        }, None
