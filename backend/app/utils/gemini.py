import google.generativeai as genai
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Retrieve API key from environment variable
api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    raise ValueError("API key not found. Please set it in the .env file.")

# Configure with your API key
genai.configure(api_key=api_key)

# Initialize the Gemini model
model = genai.GenerativeModel("gemini-1.5-flash")

def generate_response(prompt: str):
    """Generate a response from Gemini based on a prompt."""
    response = model.generate_content(prompt)
    return response.text

