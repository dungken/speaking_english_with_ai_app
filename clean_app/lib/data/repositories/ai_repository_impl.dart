import 'dart:convert';
import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:translator_plus/translator_plus.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/remote_data_source.dart';

class AiRepositoryImpl implements AiRepository {
  final String apiKey;
  final String baseUrl = 'https://api.openai.com/v1';

  AiRepositoryImpl({required this.apiKey});

  @override
  Future<String> getAnswer(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': question}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get AI response: ${response.body}');
      }
    } catch (e) {
      log('Error in getAnswer: $e');
      return 'Something went wrong (Try again later)';
    }
  }

  @override
  Future<List<String>> searchAiImages(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 4,
          'size': '1024x1024',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(
          data['data'].map((image) => image['url'] as String),
        );
      } else {
        throw Exception('Failed to generate images: ${response.body}');
      }
    } catch (e) {
      log('Error in searchAiImages: $e');
      return [];
    }
  }

  @override
  Future<ChatMessage> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': message}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        return ChatMessage.ai(aiResponse);
      } else {
        throw Exception('Failed to get AI response: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error communicating with AI service: $e');
    }
  }

  @override
  Future<String> translateText(String text, String targetLanguage) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Translate the following text to $targetLanguage: $text'
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to translate text: ${response.body}');
      }
    } catch (e) {
      log('Error in translateText: $e');
      return 'Something went wrong!';
    }
  }

  @override
  Future<String> generateImage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'][0]['url'];
      } else {
        throw Exception('Failed to generate image: ${response.body}');
      }
    } catch (e) {
      log('Error in generateImage: $e');
      return '';
    }
  }
}
