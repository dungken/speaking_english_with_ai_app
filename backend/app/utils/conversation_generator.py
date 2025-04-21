import logging
from typing import Dict, Any, Optional, List

from app.utils.gemini import generate_response

logger = logging.getLogger(__name__)

class ConversationGenerator:
    """
    Service for generating AI responses in conversations.
    
    This class provides functionality to:
    1. Generate AI responses based on conversation context
    2. Enhance basic scenarios with more detail and context
    """
    
    def generate_ai_response(self, context: Dict[str, Any]) -> str:
        """
        Generate an AI response based on conversation context.
        
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
        
        Args:
            basic_scenario: Basic description of a conversation scenario
            
        Returns:
            Enhanced scenario with detailed context
            
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
        
        Args:
            context: Conversation context
            
        Returns:
            Formatted prompt string
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
        
        Args:
            context: Conversation context
            
        Returns:
            Fallback response string
        """
        ai_role = context.get("ai_role", "Teacher")
        
        return f"I'm sorry, I'm having trouble formulating my thoughts as your {ai_role}. Could you tell me more about what you were saying?"
    
    def _generate_fallback_scenario(self, basic_scenario: str) -> Dict[str, Any]:
        """
        Generate a fallback enhanced scenario.
        
        Args:
            basic_scenario: Basic scenario description
            
        Returns:
            Fallback enhanced scenario dictionary
        """
        return {
            "enhanced_description": basic_scenario,
            "learning_goals": ["Practice speaking in everyday situations", "Build vocabulary"],
            "user_role": "Student",
            "ai_role": "Teacher",
            "starting_message": "Hello! How can I help you practice your English today?"
        } 