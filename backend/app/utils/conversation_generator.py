import logging
from typing import Dict, Any, Optional, List

from app.utils.gemini import generate_response

logger = logging.getLogger(__name__)

class ConversationGenerator:
    """
    Service for generating AI responses in conversations.
    
    This class manages the AI-driven conversation aspects of the application:
    1. Generating contextually appropriate AI responses based on conversation history
    2. Enhancing basic scenarios with rich details for better language practice
    3. Creating personalized role-based conversation contexts
    """
    
    def generate_ai_response(self, context: Dict[str, Any]) -> str:
        """
        Generate an AI response based on conversation context.
        
        This function creates a natural-sounding response from the AI based on the 
        conversation history, user/AI roles, and situation context. It uses the
        Gemini model to generate appropriate, contextually relevant responses.
        
        Args:
            context: Conversation context including roles, situation, and history
            
        Returns:
            Generated AI response text
            
        Raises:
            GenerationError: If AI response generation fails
        """
        try:
            # Build prompt
            prompt = self._build_response_prompt(context)
            
            # Generate response
            response = generate_response(prompt)
            
            # Clean up response if needed
            response = response.strip()
            
            return response
            
        except Exception as e:
            logger.error(f"Error generating AI response: {str(e)}")
            return self._generate_fallback_response(context)
    
    def enhance_scenario(self, basic_scenario: str) -> Dict[str, Any]:
        """
        Enhance a basic scenario description with more detail.
        
        This function takes a simple scenario description and expands it into a
        comprehensive language learning context with defined roles, learning goals,
        and a starting message. It transforms basic prompts like "At a restaurant" 
        into detailed conversation scenarios.
        
        Args:
            basic_scenario: Basic description of a conversation scenario
            
        Returns:
            Enhanced scenario with detailed context including:
              - enhanced_description: Detailed scenario
              - learning_goals: Language learning objectives
              - user_role: Role for the language learner
              - ai_role: Role for the AI conversation partner
              - starting_message: Initial message to begin the conversation
            
        Raises:
            GenerationError: If scenario enhancement fails
        """
        try:
            # Build prompt
            prompt = f"""
            You are a creative language learning scenario designer. 
            Enhance the following basic conversation scenario with more details, context, and learning goals.
            
            Basic scenario: "{basic_scenario}"
            
            Generate a response in JSON format with the following fields:
            - enhanced_description: A more detailed description of the scenario
            - learning_goals: 2-3 specific language learning goals for this scenario
            - user_role: Suggested role for the user
            - ai_role: Suggested role for the AI assistant
            - starting_message: A suggested first message from the AI to start the conversation
            
            Make it engaging, realistic, and focused on language learning.
            """
            
            # Generate enhanced scenario
            response = generate_response(prompt)
            
            # Parse JSON response
            import json
            try:
                enhanced = json.loads(response)
                return enhanced
            except json.JSONDecodeError:
                logger.error("Failed to parse JSON response for scenario enhancement")
                return self._generate_fallback_scenario(basic_scenario)
                
        except Exception as e:
            logger.error(f"Error enhancing scenario: {str(e)}")
            return self._generate_fallback_scenario(basic_scenario)
    
    def _build_response_prompt(self, context: Dict[str, Any]) -> str:
        """
        Build a prompt for generating an AI response.
        
        This helper function constructs a detailed prompt for the Gemini model
        that includes all relevant context for generating a natural, in-character
        response that maintains the conversation flow and pedagogical goals.
        
        Args:
            context: Conversation context
            
        Returns:
            Formatted prompt string for the AI model
        """
        user_role = context.get("user_role", "Student")
        ai_role = context.get("ai_role", "Teacher")
        situation = context.get("situation", "General conversation")
        previous_exchanges = context.get("previous_exchanges", "")
        
        prompt = f"""
        You are playing the role of {ai_role} in a conversation with a {user_role}.
        The situation is: {situation}
        
        Here is the conversation so far:
        {previous_exchanges}
        
        Generate the next response from the {ai_role} that:
        1. Maintains the role and situation
        2. Uses natural, conversational language appropriate for the context
        3. Encourages further conversation
        4. Keeps the response concise (1-3 sentences)
        
        Respond directly as the {ai_role} without any meta-commentary or additional text.
        """
        
        return prompt
    
    def _generate_fallback_response(self, context: Dict[str, Any]) -> str:
        """
        Generate a fallback response when AI generation fails.
        
        This function provides a graceful degradation option if the main AI
        generation process encounters an error, ensuring the conversation
        can continue even when technical issues arise.
        
        Args:
            context: Conversation context
            
        Returns:
            Fallback response string that acknowledges the issue while staying in role
        """
        ai_role = context.get("ai_role", "Teacher")
        
        return f"I'm sorry, I'm having trouble formulating my thoughts as your {ai_role}. Could you tell me more about what you were saying?"
    
    def _generate_fallback_scenario(self, basic_scenario: str) -> Dict[str, Any]:   
        """
        Generate a fallback enhanced scenario.
        
        This function creates a basic but functional scenario enhancement when
        the AI-powered enhancement process fails, ensuring the conversation
        system can continue to function with reasonable defaults.
        
        Args:
            basic_scenario: Basic scenario description
            
        Returns:
            Fallback enhanced scenario dictionary with simple defaults
        """
        return {
            "enhanced_description": basic_scenario,
            "learning_goals": ["Practice speaking in everyday situations", "Build vocabulary"],
            "user_role": "Student",
            "ai_role": "Teacher",
            "starting_message": "Hello! How can I help you practice your English today?"
        }