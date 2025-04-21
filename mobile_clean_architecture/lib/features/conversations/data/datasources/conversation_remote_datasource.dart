import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/feedback.dart';
import '../../domain/entities/message.dart';
import '../models/conversation_model.dart';
import '../models/feedback_model.dart';
import '../models/message_model.dart';

abstract class ConversationRemoteDataSource {
  /// Creates a new conversation with the given parameters
  ///
  /// Throws a [ServerException] if something goes wrong
  Future<ConversationModel> createConversation({
    required String userRole,
    required String aiRole,
    required String situation,
  });

  /// Gets a specific conversation by ID
  ///
  /// Throws a [ServerException] if not found or another error occurs
  Future<ConversationModel> getConversation(String id);

  /// Gets all conversations for the current user
  ///
  /// Throws a [ServerException] if something goes wrong
  Future<List<ConversationModel>> getUserConversations();

  /// Adds a message to a conversation
  ///
  /// Throws a [ServerException] if something goes wrong
  Future<ConversationModel> addMessage({
    required String conversationId,
    required SenderType sender,
    required String content,
    String? audioPath,
    String? transcription,
  });

  /// Gets the AI response for a conversation
  ///
  /// Throws a [ServerException] if something goes wrong
  Future<MessageModel> getAiResponse({
    required ConversationModel conversation,
  });

  /// Generates feedback on a user's message
  ///
  /// Throws a [ServerException] if something goes wrong
  Future<FeedbackModel> generateFeedback({
    required String conversationId,
    required String messageId,
    required String audioPath,
    required String transcription,
  });
}

class ConversationRemoteDataSourceImpl implements ConversationRemoteDataSource {
  final http.Client client;

  ConversationRemoteDataSourceImpl({required this.client});

  @override
  Future<ConversationModel> createConversation({
    required String userRole,
    required String aiRole,
    required String situation,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/api/conversations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConstants.token}',
      },
      body: jsonEncode({
        'user_role': userRole,
        'ai_role': aiRole,
        'situation': situation,
      }),
    );

    if (response.statusCode == 201) {
      return ConversationModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        message: 'Failed to create conversation: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<ConversationModel> getConversation(String id) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/api/conversations/$id'),
      headers: {
        'Authorization': 'Bearer ${ApiConstants.token}',
      },
    );

    if (response.statusCode == 200) {
      return ConversationModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        message: 'Failed to get conversation: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<List<ConversationModel>> getUserConversations() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/api/conversations'),
      headers: {
        'Authorization': 'Bearer ${ApiConstants.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> conversationsJson = jsonDecode(response.body);
      return conversationsJson
          .map((json) => ConversationModel.fromJson(json))
          .toList();
    } else {
      throw ServerException(
        message: 'Failed to get conversations: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<ConversationModel> addMessage({
    required String conversationId,
    required SenderType sender,
    required String content,
    String? audioPath,
    String? transcription,
  }) async {
    // If an audio file is provided, first upload it
    String? fileId;
    if (audioPath != null) {
      fileId = await _uploadAudioFile(audioPath);
    }

    // Add the message to the conversation
    final response = await client.post(
      Uri.parse(
          '${ApiConstants.baseUrl}/api/conversations/$conversationId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConstants.token}',
      },
      body: jsonEncode({
        'sender': sender == SenderType.user ? 'user' : 'ai',
        'content': content,
        'audio_path': audioPath,
        'transcription': transcription,
      }),
    );

    if (response.statusCode == 201) {
      return ConversationModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        message: 'Failed to add message: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<MessageModel> getAiResponse({
    required ConversationModel conversation,
  }) async {
    final response = await client.post(
      Uri.parse(
          '${ApiConstants.baseUrl}/api/conversations/${conversation.id}/ai-response'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConstants.token}',
      },
    );

    if (response.statusCode == 200) {
      return MessageModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        message: 'Failed to get AI response: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<FeedbackModel> generateFeedback({
    required String conversationId,
    required String messageId,
    required String audioPath,
    required String transcription,
  }) async {
    // First, we need to analyze the audio
    final analyzeResponse = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/api/audio/analyze-local'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConstants.token}',
      },
      body: jsonEncode({
        'file_path': audioPath,
        'language': 'en-US',
        'reference_text': transcription,
      }),
    );

    if (analyzeResponse.statusCode != 200) {
      throw ServerException(
        message: 'Failed to analyze audio: ${analyzeResponse.statusCode}',
        statusCode: analyzeResponse.statusCode,
      );
    }

    final analyzeResult = jsonDecode(analyzeResponse.body);

    // Now, generate feedback using the analysis results
    final feedbackResponse = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/api/feedback/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConstants.token}',
      },
      body: jsonEncode({
        'conversation_id': conversationId,
        'message_id': messageId,
        'transcription': transcription,
        'pronunciation_score': analyzeResult['pronunciation']['overall_score'],
        'context': {
          'conversation_type': 'role_play',
        },
      }),
    );

    if (feedbackResponse.statusCode == 200) {
      return FeedbackModel.fromJson(jsonDecode(feedbackResponse.body));
    } else {
      throw ServerException(
        message: 'Failed to generate feedback: ${feedbackResponse.statusCode}',
        statusCode: feedbackResponse.statusCode,
      );
    }
  }

  /// Helper method to upload an audio file
  ///
  /// Returns the file ID if successful
  Future<String> _uploadAudioFile(String filePath) async {
    // Create a multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/api/audio/upload-file'),
    );

    // Add authorization header
    request.headers.addAll({
      'Authorization': 'Bearer ${ApiConstants.token}',
    });

    // Add file
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
    ));

    // Add additional fields
    request.fields['language'] = 'en-US';

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['_id'];
    } else {
      throw ServerException(
        message: 'Failed to upload audio file: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}
