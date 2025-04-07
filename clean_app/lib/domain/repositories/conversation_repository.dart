import '../entities/conversation.dart';
import '../entities/chat_message.dart';

/// Repository interface for conversation-related operations
abstract class ConversationRepository {
  /// Create a new conversation
  Future<Map<String, dynamic>> createConversation(Conversation conversation);

  /// Send a message in a conversation
  Future<Map<String, dynamic>> sendMessage(
      String conversationId, String message);

  /// Get conversation history
  Future<List<ChatMessage>> getConversationHistory(String conversationId);

  /// End a conversation and get feedback
  Future<Map<String, dynamic>> endConversation(String conversationId);
}
