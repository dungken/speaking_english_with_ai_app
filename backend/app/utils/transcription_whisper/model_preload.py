import torch
import os
import logging
from transcription import model_pool, get_device

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def preload_model():
    """
    Preload model into memory to avoid cold start delays
    
    Args:
        model_size: Size of the Whisper model to use ('tiny', 'base', 'small', 'medium', 'large-v3', 'turbo')
        use_hf: Whether to use the HuggingFace model instead of the original Whisper model
    """
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    device = get_device()
    
    return model


