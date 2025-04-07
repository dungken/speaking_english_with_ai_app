import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/entities/conversation.dart';

/// 🌐 **Conversation Repository Implementation**
///
/// Handles all API calls related to conversations.
class ConversationRepositoryImpl implements ConversationRepository {
  static const String _baseUrl =
      'http://localhost:8000'; // Update with your backend URL

  /// 📝 Create a new conversation
  @override
  Future<Map<String, dynamic>> createConversation(
      Conversation conversation) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/conversations'),
        headers: {
          'Content-Type': 'application/json',
          // Add any auth headers if needed
        },
        body: jsonEncode(conversation.toJson()),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create conversation: ${response.body}');
      }
    } catch (e) {
      log('Error in createConversation: $e');
      throw Exception('Network error: $e');
    }
  }

  /// 💬 Send a message in a conversation
  @override
  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String message,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/conversations/$conversationId/messages'),
        headers: {
          'Content-Type': 'application/json',
          // Add any auth headers if needed
        },
        body: jsonEncode({
          'text': message,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      log('Error in sendMessage: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getConversationHistory(
      String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/conversations/$conversationId/messages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['messages'] as List)
            .map((msg) => ChatMessage(
                  id: msg['id'],
                  content: msg['text'],
                  isUser: msg['is_user'],
                  timestamp: DateTime.parse(msg['timestamp']),
                ))
            .toList();
      } else {
        throw Exception('Failed to get conversation history: ${response.body}');
      }
    } catch (e) {
      log('Error in getConversationHistory: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> endConversation(String conversationId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/conversations/$conversationId/end'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to end conversation: ${response.body}');
      }
    } catch (e) {
      log('Error in endConversation: $e');
      throw Exception('Network error: $e');
    }
  }
}
