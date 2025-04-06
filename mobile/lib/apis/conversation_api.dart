// lib/apis/conversation_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/conversation.dart';
import '../model/message.dart';
import '../helper/api_config.dart';

/// 🌐 **Conversation API Service**
///
/// Handles all API calls related to conversations.
class ConversationApi {
  final String baseUrl = ApiConfig.baseUrl;

  /// 📝 Create a new conversation
  Future<ConversationResponse> createConversation({
    required String userRole,
    required String aiRole,
    required String situation,
    required String token,
  }) async {
    try {
      print('Creating conversation with URL: $baseUrl/conversations');
      print('Request body: ${jsonEncode({
            'user_role': userRole,
            'ai_role': aiRole,
            'situation': situation,
          })}');

      final response = await http.post(
        Uri.parse('$baseUrl/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_role': userRole,
          'ai_role': aiRole,
          'situation': situation,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return ConversationResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Nhat Failed to create conversation: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error creating conversation: $e');
      rethrow;
    }
  }

  /// 💬 Send a message in a conversation
  Future<MessageResponse> sendMessage({
    required String conversationId,
    required String text,
    String? audioUrl,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/conversations/$conversationId/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'audio_url': audioUrl,
      }),
    );

    if (response.statusCode == 200) {
      return MessageResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }
}
