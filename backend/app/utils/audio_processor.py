"""
Audio processing utilities for transcription and pronunciation assessment using Azure Cognitive Services.

This module provides functionality for:
1. Audio file transcription using Azure Speech-to-Text
2. Pronunciation assessment and scoring using Azure Speech Services
3. Generating language feedback using Azure AI or alternative models
"""

import os
import json
import tempfile
import requests
import logging
import time
from typing import Dict, Any, Optional, Tuple, List
from dotenv import load_dotenv
import azure.cognitiveservices.speech as speechsdk
import google.generativeai as genai

# Load environment variables
load_dotenv()

# Configure Google Generative AI (for feedback generation)
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
gemini_model = genai.GenerativeModel("gemini-1.5-flash")

# Azure Speech Configuration
AZURE_SPEECH_KEY = os.getenv("AZURE_SPEECH_KEY")
AZURE_SPEECH_REGION = os.getenv("AZURE_SPEECH_REGION", "eastus")

# Initialize logger
logger = logging.getLogger(__name__)

def create_speech_config():
    """Create and return an Azure Speech Config object"""
    if not AZURE_SPEECH_KEY:
        logger.error("Azure Speech Key not configured")
        raise ValueError("Azure Speech Services not properly configured")
    
    speech_config = speechsdk.SpeechConfig(
        subscription=AZURE_SPEECH_KEY, 
        region=AZURE_SPEECH_REGION
    )
    # Set speech recognition language
    speech_config.speech_recognition_language = "en-US"
    
    return speech_config

def download_audio_file(audio_url: str) -> str:
    """
    Download audio file from URL and save to temporary file
    
    Args:
        audio_url: URL to the audio file
        
    Returns:
        Path to the temporary file
    """
    # Download the audio file from the URL
    response = requests.get(audio_url)
    
    if response.status_code != 200:
        raise ValueError(f"Failed to download audio file: {response.status_code}")
        
    # Save to a temporary file
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_file:
        temp_file.write(response.content)
        return temp_file.name

def transcribe_audio(audio_url: str, language_code: str = "en-US") -> Dict[str, Any]:
    """
    Transcribe audio file using Azure Speech-to-Text API.
    
    Args:
        audio_url: URL to the audio file
        language_code: Language code for transcription (default: en-US)
        
    Returns:
        Dictionary containing transcription text and confidence
        
    Raises:
        ValueError: If transcription fails
    """
    temp_file_path = None
    
    try:
        # Download the audio file
        temp_file_path = download_audio_file(audio_url)
        
        # Create speech configuration
        speech_config = create_speech_config()
        speech_config.speech_recognition_language = language_code
        
        # Create audio configuration using the temporary file
        audio_config = speechsdk.audio.AudioConfig(filename=temp_file_path)
        
        # Create speech recognizer
        speech_recognizer = speechsdk.SpeechRecognizer(
            speech_config=speech_config, 
            audio_config=audio_config
        )
        
        # Define result variables
        all_results = []
        confidence_sum = 0
        confidence_count = 0
        
        # Define callback functions
        def recognized_cb(evt):
            # Add recognized text to results list
            all_results.append(evt.result.text)
            
            # Add confidence score if available
            # Note: Azure doesn't provide word-level confidence for all languages/scenarios
            # This is an approximation
            nonlocal confidence_sum, confidence_count
            confidence_sum += 0.8  # Default confidence if not available
            confidence_count += 1
        
        def canceled_cb(evt):
            if evt.reason == speechsdk.CancellationReason.Error:
                logger.error(f"Speech recognition canceled: {evt.error_details}")
                raise ValueError(f"Speech recognition error: {evt.error_details}")
        
        # Connect callbacks
        speech_recognizer.recognized.connect(recognized_cb)
        speech_recognizer.canceled.connect(canceled_cb)
        
        # Start recognition and wait for completion
        speech_recognizer.start_continuous_recognition()
        
        # Wait for processing to complete (adjust timeout as needed)
        time.sleep(5)  # Simple approach - a more robust solution would use events
        speech_recognizer.stop_continuous_recognition()
        
        # Combine results
        text = " ".join(all_results)
        confidence = confidence_sum / confidence_count if confidence_count > 0 else 0
            
        return {
            "text": text,
            "confidence": confidence
        }
            
    except Exception as e:
        logger.error(f"Error transcribing audio: {str(e)}")
        raise ValueError(f"Transcription failed: {str(e)}")
    
    finally:
        # Clean up the temporary file
        if temp_file_path and os.path.exists(temp_file_path):
            os.remove(temp_file_path)

def assess_pronunciation(audio_url: str, transcription: str, reference_text: Optional[str] = None) -> Dict[str, Any]:
    """
    Assess pronunciation quality of an audio recording using Azure's pronunciation assessment.
    
    Args:
        audio_url: URL to the audio file
        transcription: Transcription of the audio
        reference_text: Optional reference text to compare against
        
    Returns:
        Dictionary containing pronunciation scores and feedback
    """
    temp_file_path = None
    
    try:
        # If no reference text is provided, use the transcription
        if not reference_text:
            reference_text = transcription
            
        # Download the audio file
        temp_file_path = download_audio_file(audio_url)
        
        # Create speech configuration
        speech_config = create_speech_config()
        
        # Create audio configuration
        audio_config = speechsdk.audio.AudioConfig(filename=temp_file_path)
        
        # Create pronunciation assessment config
        pronunciation_config = speechsdk.PronunciationAssessmentConfig(
            reference_text=reference_text,
            grading_system=speechsdk.PronunciationAssessmentGradingSystem.HundredMark,
            granularity=speechsdk.PronunciationAssessmentGranularity.Phoneme,
            enable_miscue=True
        )
        
        # Create speech recognizer and attach pronunciation assessment
        speech_recognizer = speechsdk.SpeechRecognizer(
            speech_config=speech_config, 
            audio_config=audio_config
        )
        pronunciation_assessment = pronunciation_config.create_pronunciation_assessment(speech_recognizer)
        
        # Start assessment
        result = speech_recognizer.recognize_once_async().get()
        
        # Get pronunciation assessment result
        pronunciation_result = speechsdk.PronunciationAssessmentResult(result)
        
        # Extract word-level scores
        word_scores = {}
        if hasattr(pronunciation_result, 'words'):
            for word in pronunciation_result.words:
                word_scores[word.word] = word.accuracy_score
                
        # Create the response structure
        assessment = {
            "overall_score": pronunciation_result.accuracy_score,
            "word_scores": word_scores,
            "improvement_suggestions": []
        }
        
        # Generate improvement suggestions using Gemini
        if transcription:
            prompt = f"""
            I need to provide 2-3 specific suggestions for improving English pronunciation based on this assessment.
            
            The learner said: "{transcription}"
            
            The reference text was: "{reference_text}"
            
            The overall pronunciation score was: {pronunciation_result.accuracy_score}/100
            
            Please provide exactly 2-3 specific, actionable suggestions for improvement.
            Format your response as a JSON array of strings.
            """
            
            # Generate the suggestions using Gemini
            response = gemini_model.generate_content(prompt)
            response_text = response.text
            
            # Extract JSON content if wrapped in markdown
            if "```json" in response_text:
                response_text = response_text.split("```json")[1].split("```")[0].strip()
            elif "```" in response_text:
                response_text = response_text.split("```")[1].split("```")[0].strip()
                
            # Parse the JSON response
            try:
                suggestions = json.loads(response_text)
                if isinstance(suggestions, list):
                    assessment["improvement_suggestions"] = suggestions
                else:
                    assessment["improvement_suggestions"] = ["Practice clear pronunciation of each syllable.", 
                                                            "Work on sentence rhythm and stress patterns."]
            except:
                assessment["improvement_suggestions"] = ["Practice clear pronunciation of each syllable.", 
                                                        "Work on sentence rhythm and stress patterns."]
        
        return assessment
        
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
    
    finally:
        # Clean up the temporary file
        if temp_file_path and os.path.exists(temp_file_path):
            os.remove(temp_file_path)

def analyze_spoken_english(audio_url: str, reference_text: Optional[str] = None) -> Dict[str, Any]:
    """
    Comprehensive analysis of spoken English including transcription, pronunciation, and language feedback.
    
    Args:
        audio_url: URL to the audio file
        reference_text: Optional reference text to compare against
        
    Returns:
        Dictionary containing transcription, pronunciation scores, and language feedback
    """
    try:
        # Step 1: Transcribe the audio
        transcription_result = transcribe_audio(audio_url)
        transcription = transcription_result["text"]
        
        # Step 2: Assess pronunciation
        pronunciation_result = assess_pronunciation(audio_url, transcription, reference_text)
        
        # Step 3: Generate language feedback
        language_feedback, _ = generate_feedback(transcription, reference_text)
        
        # Combine results
        return {
            "transcription": transcription,
            "confidence": transcription_result.get("confidence", 0),
            "pronunciation": pronunciation_result,
            "language_feedback": language_feedback
        }
    
    except Exception as e:
        logger.error(f"Error in comprehensive analysis: {str(e)}")
        raise ValueError(f"Analysis failed: {str(e)}")

def generate_feedback(user_text: str, reference_text: Optional[str] = None) -> Tuple[Dict[str, Any], Optional[Dict[str, Any]]]:
    """
    Generate language feedback for user's text using Gemini AI.
    
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

def extract_mistakes_from_feedback(feedback: Dict[str, Any], user_text: str) -> List[Dict[str, Any]]:
    """
    Extract structured mistake entries from feedback for the mistake tracking system.
    
    Args:
        feedback: Feedback dictionary with grammar, vocabulary, and fluency issues
        user_text: Original text from the user
        
    Returns:
        List of mistake objects ready to be stored in the database
    """
    mistakes = []
    
    # Process grammar issues
    if "grammar" in feedback and isinstance(feedback["grammar"], list):
        for item in feedback["grammar"]:
            if isinstance(item, dict) and "issue" in item and "correction" in item:
                mistakes.append({
                    "type": "GRAMMAR",
                    "original_content": item.get("issue", ""),
                    "correction": item.get("correction", ""),
                    "explanation": item.get("explanation", "Grammar issue"),
                    "context": user_text,
                    "severity": 2  # Medium severity by default
                })
    
    # Process vocabulary issues
    if "vocabulary" in feedback and isinstance(feedback["vocabulary"], list):
        for item in feedback["vocabulary"]:
            if isinstance(item, dict) and "original" in item and "suggestion" in item:
                mistakes.append({
                    "type": "VOCABULARY",
                    "original_content": item.get("original", ""),
                    "correction": item.get("suggestion", ""),
                    "explanation": item.get("context", "Vocabulary improvement"),
                    "context": user_text,
                    "severity": 1  # Lower severity by default
                })
    
    # Process fluency issues
    if "fluency" in feedback and isinstance(feedback["fluency"], list):
        for item in feedback["fluency"]:
            if isinstance(item, str) and item.strip():
                mistakes.append({
                    "type": "FLUENCY",
                    "original_content": "Flow issue",
                    "correction": item,
                    "explanation": "Improve natural flow and expression",
                    "context": user_text,
                    "severity": 1  # Lower severity by default
                })
    
    return mistakes
