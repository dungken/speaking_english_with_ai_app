from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse
from typing import List, Dict, Optional
import os
import random
from pathlib import Path
import json

from app.utils.image_description import get_image_description
from app.utils.gemini import generate_response
from pydantic import BaseModel

router = APIRouter(prefix="/api/images", tags=["images"])
# i want to prototype this feature quickly so use  json file to store record
# Get the absolute paths
IMAGES_DIR = Path(__file__).parent.parent / "uploads" / "images"
FAKE_DB_DIR = Path(__file__).parent.parent / "uploads" / "fake-db"
JSON_FILE = FAKE_DB_DIR / "image_descriptions.json"
FEEDBACK_FILE = FAKE_DB_DIR / "image_feedback.json"

# Define the feedback request model
class ImageFeedbackRequest(BaseModel):
    user_id: str
    image_id: str
    user_transcription: str

# Define the feedback response model
class ImageFeedbackResponse(BaseModel):
    better_version: Optional[str] = None
    explanation: Optional[str] = None

def load_image_data() -> List[Dict]:
    """Load complete image data from JSON file"""
    if JSON_FILE.exists():
        with open(JSON_FILE, 'r') as f:
            return json.load(f)
    return []

def save_image_data(image_data: List[Dict]):
    """Save complete image data to JSON file"""
    FAKE_DB_DIR.mkdir(parents=True, exist_ok=True)
    with open(JSON_FILE, 'w') as f:
        json.dump(image_data, f, indent=2)

def load_feedback_data() -> List[Dict]:
    """Load image feedback data from JSON file"""
    if FEEDBACK_FILE.exists():
        with open(FEEDBACK_FILE, 'r') as f:
            return json.load(f)
    return []

def save_feedback_data(feedback_data: List[Dict]):
    """Save image feedback data to JSON file"""
    FAKE_DB_DIR.mkdir(parents=True, exist_ok=True)
    with open(FEEDBACK_FILE, 'w') as f:
        json.dump(feedback_data, f, indent=2)


@router.get("/practice", response_model=List[dict])
async def get_practice_images():
    """
    Returns a list of practice images with IDs and URLs
    """
    try:
        # Load existing image data
        saved_images = load_image_data()
        saved_image_dict = {img["name"]: img for img in saved_images}
        
        # List all image files in the uploads/images directory
        image_files = [f for f in os.listdir(IMAGES_DIR) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
        
        if not image_files:
            return []

        updated_images = []
        data_updated = False

        for image_file in image_files:
            image_url = f"/uploads/images/{image_file}"
            img_path = str(IMAGES_DIR / image_file)
            
            # Check if we already have this image in our saved data
            if image_url in saved_image_dict:
                saved_image = saved_image_dict[image_url]
                # Check if we need to regenerate the description
                # if not saved_image.get("detail_description") or saved_image["detail_description"] == "Could not generate image description.":
                if not saved_image.get("detail_description"):
                    # Generate a new description using the image path
                    saved_image["detail_description"] = get_image_description(img_path)
                    data_updated = True
                updated_images.append(saved_image)
            else:
                # Generate new entry for this image
                detail_description = get_image_description(img_path)
                
                new_image_data = {
                    "id": str(random.randint(1000, 9999)),
                    "name": image_url,
                    "detail_description": detail_description
                }
                updated_images.append(new_image_data)
                data_updated = True

        # Save updated data if we added any new images
        if data_updated:
            save_image_data(updated_images)

        return updated_images

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{image_id}")
async def get_image_by_id(image_id: str):
    """
    Returns the actual image file by its ID
    """
    try:
        # Load existing image data
        saved_images = load_image_data()
        
        # Find the image with the matching ID
        for image in saved_images:
            if image["id"] == image_id:
                # Extract filename from the image URL (stored in "name" field)
                # The URL format is "/uploads/images/{filename}"
                image_url = image["name"]
                filename = os.path.basename(image_url)
                
                # Construct the full path to the image file
                image_path = IMAGES_DIR / filename
                
                # Check if the file exists
                if not image_path.exists():
                    raise HTTPException(status_code=404, detail="Image file not found on server")
                
                # Return the actual image file as a response
                return FileResponse(image_path)
        
        # If no image is found with the given ID, raise 404 error
        raise HTTPException(status_code=404, detail="Image not found")

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/feedback", response_model=ImageFeedbackResponse)
async def provide_feedback(feedback_request: ImageFeedbackRequest):
    """
    Accepts user feedback on image description and returns an improved version
    """
    try:
        feedback_data = load_feedback_data()
        
        # Generate a unique ID for the new feedback entry
        feedback_id = str(random.randint(1000, 9999))
          # Prepare the prompt for Gemini
        image_data = next((img for img in load_image_data() if img["id"] == feedback_request.image_id), None)
        
        if not image_data:
            raise HTTPException(status_code=404, detail="Image not found")
        
        detail_description = image_data.get('detail_description', 'No description available')
        
        prompt = f"""Detail description of image: '{detail_description}'.
User description: '{feedback_request.user_transcription}'.

Based on the 'Detail description of image' (which serves as a correct and comprehensive reference) and the 'User description' provided above, your task is to analyze the user description and then generate a JSON object as a string.
better_version will be the improved version of the user description that is grammatically correct, coherent, and more descriptive.
explanation will be a brief explanation of the changes made to the user description, highlighting the improvements and clarifications.
This JSON object must have the following exact structure:

{{
"better_version": "<generated_description>",
"explanation": "<generated_explanation>"
}}
"""
          # Get the improved description from Gemini
        try:
            gemini_response = generate_response(prompt)
            cleaned_response = gemini_response.strip("```json\n").strip("\n```").strip("```")
            data = json.loads(cleaned_response)
            # Extract the better version and explanation from Gemini's response
            better_version = data.get("better_version", "")
            explanation = data.get("explanation", "")
        except json.JSONDecodeError as e:
            # Fallback if JSON parsing fails
            better_version = "Could not generate improved version"
            explanation = "There was an error processing the feedback"
        except Exception as e:
            # General fallback
            better_version = "Could not generate improved version"
            explanation = f"Error: {str(e)}"
        
        # Create a new feedback entry
        new_feedback = {
            "id": feedback_id,
            "user_id": feedback_request.user_id,
            "image_id": feedback_request.image_id,
            "user_transcription": feedback_request.user_transcription,
            "feedback": {
                "better_version": better_version,
                "explanation": explanation
            }
        }
        
        # Add the new feedback to the existing data
        feedback_data.append(new_feedback)
        
        # Save the updated feedback data
        save_feedback_data(feedback_data)
        
        return {"better_version": better_version, "explanation": explanation}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))





