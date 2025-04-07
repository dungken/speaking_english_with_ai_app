/// Repository interface for AI-related operations
import '../entities/chat_message.dart';

abstract class AiRepository {
  /// Get AI-generated answer for a question
  Future<String> getAnswer(String question);

  /// Search for AI-generated images based on a prompt
  Future<List<String>> searchAiImages(String prompt);

  /// Translate text from one language to another
  Future<String> translateText(String text, String targetLanguage);

  Future<ChatMessage> sendMessage(String message);
  Future<String> generateImage(String prompt);
}
