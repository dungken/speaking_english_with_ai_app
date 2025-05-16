import subprocess
import sys

# Try to import Whisper and check available models
try:
    import whisper
    print("Current whisper version:", whisper.__version__)
    print("Available models:", whisper.available_models())
except Exception as e:
    print(f"Error: {e}")
