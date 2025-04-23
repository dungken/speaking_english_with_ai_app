import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/message.dart';
import '../models/conversation_model.dart';
import '../models/feedback_model.dart';
import '../models/message_model.dart';

abstract class ConversationRemoteDataSource {
  /// Creates a new conversation with the given parameters
  ///
  /// Throws a [ServerException] if something goes wrong
  Future<Map<String, dynamic>> createConversation({
    required String userRole,
    required String aiRole,
    required String situation,
  });

  /// Gets all conversations for the current user
  ///
  /// Throws a [ServerException] if something goes wrong
  Future<List<ConversationModel>> getUserConversations({
    int page = 1,
    int limit = 10,
  });

  /// Send a speech message and receive AI response
  ///
  /// Throws a [ServerException] if something goes wrong
  Future<Map<String, dynamic>> sendSpeechMessage({
    required String conversationId,
    required String audioId,
  });

  /// Get feedback for a specific message
  ///
  /// Throws a [ServerException] if something goes wrong
  Future<FeedbackModel> getMessageFeedback(String messageId);

  /// Retrieves a specific conversation by its ID
  ///
  /// Throws a [ServerException] if not found or other error occurs
  Future<ConversationModel> getConversation(String id);
}

class ConversationRemoteDataSourceImpl implements ConversationRemoteDataSource {
  final http.Client client;

  ConversationRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> createConversation({
    required String userRole,
    required String aiRole,
    required String situation,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.conversationsEndpoint}'),
        headers: ApiConstants.authHeaders,
        body: jsonEncode({
          'user_role': userRole,
          'ai_role': aiRole,
          'situation': situation,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Extract the conversation and initial message from response
        final conversationData = responseData['conversation'];
        final initialMessageData = responseData['initial_message'];
        
        // Parse into models
        final conversation = ConversationModel.fromJson(conversationData);
        final initialMessage = MessageModel.fromJson(initialMessageData);
        
        return {
          'conversation': conversation,
          'initial_message': initialMessage,
        };
      } else {
        throw ServerException(
          message: 'Failed to create conversation: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Error creating conversation: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<ConversationModel>> getUserConversations({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.conversationsEndpoint}?page=$page&limit=$limit'),
        headers: ApiConstants.authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> conversationsJson = responseData['conversations'];
        return conversationsJson
            .map((json) => ConversationModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to get conversations: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Error getting conversations: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> sendSpeechMessage({
    required String conversationId,
    required String audioId,
  }) async {
    try {
      final endpoint = ApiConstants.messageEndpoint
          .replaceFirst('{conversation_id}', conversationId);

      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: ApiConstants.authHeaders,
        body: jsonEncode({
          'audio_id': audioId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Extract user message and AI message
        final userMessageData = responseData['user_message'];
        final aiMessageData = responseData['ai_message'];
        
        // Parse into model objects
        final userMessage = MessageModel.fromJson(userMessageData);
        final aiMessage = MessageModel.fromJson(aiMessageData);
        
        return {
          'user_message': userMessage,
          'ai_message': aiMessage,
        };
      } else {
        throw ServerException(
          message: 'Failed to send message: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Error sending message: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<FeedbackModel> getMessageFeedback(String messageId) async {
    try {
      final endpoint =
          ApiConstants.feedbackEndpoint.replaceFirst('{message_id}', messageId);

      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: ApiConstants.authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['is_ready'] == true) {
          final feedbackData = responseData['user_feedback'];
          
          // Parse the simplified feedback structure
          return FeedbackModel(
            id: feedbackData is Map<String, dynamic> ? feedbackData['id'] ?? messageId : messageId,
            userFeedback: feedbackData is Map<String, dynamic> ? 
                         feedbackData['user_feedback'] ?? 'Feedback unavailable' : 
                         feedbackData.toString(),
            createdAt: feedbackData is Map<String, dynamic> && feedbackData.containsKey('created_at') ?
                      DateTime.parse(feedbackData['created_at']) : 
                      DateTime.now(),
            detailedFeedback: null, // No detailed feedback in the API response
          );
        } else {
          // Feedback not ready yet
          throw const FeedbackProcessingException(
            message: 'Feedback is still being generated. Please try again in a moment.',
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to get feedback: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException || e is FeedbackProcessingException) {
        rethrow;
      }
      throw ServerException(
        message: 'Error getting feedback: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ConversationModel> getConversation(String id) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.conversationsEndpoint}/$id'),
        headers: ApiConstants.authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ConversationModel.fromJson(responseData);
      } else {
        throw ServerException(
          message: 'Failed to get conversation: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Error getting conversation: $e',
        statusCode: 500,
      );
    }
  }
}

class FeedbackProcessingException implements Exception {
  final String message;

  const FeedbackProcessingException({required this.message});
}
