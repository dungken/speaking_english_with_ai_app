
import os 
from google import genai


GOOGLE_API_KEY = os.getenv("GEMINI_API_KEY")
client = genai.Client(api_key=GOOGLE_API_KEY)

prompt = """ Generate a concise and objective description of the provided image, 
suitable for a TOEIC picture description test. The description should be spoken aloud 
in approximately 30-45 seconds. Focus on the following elements in this order: 
1. Overall Scene/Main Idea: Begin with a single sentence summarizing what is generally 
happening or what the image primarily depicts. 2. People: State the number of people 
visible. Describe their main actions or activities. Briefly mention their attire if
it's distinctive or relevant. If facial expressions are clear and unambiguous, briefly 
note them (e.g., "smiling," "concentrating"). Avoid guessing emotions. 
3. Key Objects and Setting: Identify prominent objects in the foreground 
and background. Describe their locations relative to each other or the people.
Clearly state whether the setting is indoors or outdoors, and specify the type 
of location if obvious (e.g., office, park, kitchen, street). 
4. Concluding Observation (Optional and Brief): If there's a very clear and
objective overall impression or atmosphere 
(e.g., "It appears to be a busy workday," "The scene looks like a casual gathering"),
you can mention it briefly. Avoid subjective interpretations or storytelling. 
Important Considerations for the AI: Use clear and precise vocabulary. 
Maintain a neutral and objective tone. Focus on what is directly visible 
in the image. Do not make assumptions or inferences beyond what is clearly 
shown. Structure the description logically. Ensure grammatical accuracy and
fluency. The output should be a direct description, not a story or interpretation
"""



def get_image_description(image_path:str = None) -> str:
    """
    Get a detailed description of the image using Google GenAI.
    
    Args:
        image_path (str): Path to the image file.
        
    Returns:
        str: Detailed description of the image.
    """
    if not image_path:
        raise ValueError("Image path must be provided.")
    
    # Upload the image
    my_file = client.files.upload(file=image_path)
    
    # Generate content
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=[my_file, prompt],
    )
    
    return response.text


