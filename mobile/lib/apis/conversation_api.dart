// lib/apis/conversation_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/conversation.dart';

/// 🌐 **Conversation API Service**
///
/// Handles all API calls related to conversations.
class ConversationApi {
  static const String _baseUrl = 'http://localhost:8000'; // Update with your backend URL

  /// 📝 Create a new conversation
  Future<Map<String, dynamic>> createConversation(Conversation conversation) async {
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
      throw Exception('Network error: $e');
    }
  }

  /// 💬 Send a message in a conversation
  Future<Map<String, dynamic>> sendMessage(String conversationId, String message) async {
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
      throw Exception('Network error: $e');
    }
  }
}