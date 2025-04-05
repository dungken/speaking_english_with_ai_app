import 'dart:convert';
import 'package:http/http.dart' as http;

class ConversationApi {
  static const String _baseUrl = 'http://127.0.0.1:8000/';

  Future<void> createConversation(Map<String, dynamic> conversationData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/conversations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(conversationData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create conversation');
    }
  }
}
