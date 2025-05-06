import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
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
      // Log request data for debugging
      final response = await client.post(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.conversationsEndpoint}'),
        headers: ApiConstants.authHeaders,
        body: jsonEncode({
          'user_role': userRole,
          'ai_role': aiRole,
          'situation': situation,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));

        // Validate the expected structure exists before trying to access it
        if (responseData['conversation'] == null) {
          throw ServerException(
            message: 'Server response missing conversation data',
            statusCode: response.statusCode,
          );
        }

        if (responseData['initial_message'] == null) {
          throw ServerException(
            message: 'Server response missing initial_message data',
            statusCode: response.statusCode,
          );
        }

        return {
          'conversation':
              ConversationModel.fromJson(responseData['conversation']),
          'initial_message':
              MessageModel.fromJson(responseData['initial_message']),
        };
      } else {
        throw ServerException(
          message:
              'Failed to create conversation: ${response.statusCode} - ${response.body}',
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
          message:
              'Failed to get conversations: ${response.statusCode} - ${response.body}',
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

      // Construct the URL with audio_id as a query parameter
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(
        queryParameters: {'audio_id': audioId},
      );

      // Send POST request with audio_id in query parameters
      final response = await client.post(
        url,
        headers: ApiConstants.authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'user_message': MessageModel.fromJson(responseData['user_message']),
          'ai_message': MessageModel.fromJson(responseData['ai_message']),
        };
      } else {
        throw ServerException(
          message:
              'Failed to send message: ${response.statusCode} - ${response.body}',
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
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        // Check if the response contains the expected data
        if (responseData['is_ready'] == true) {
          final feedbackData = responseData['user_feedback'];

          if (feedbackData is String) {
            // Simple string feedback
            return FeedbackModel(
              id: messageId,
              userFeedback: feedbackData,
              createdAt: DateTime.now(),
              detailedFeedback: null,
            );
          } else if (feedbackData is Map<String, dynamic>) {
            // Full feedback object
            return FeedbackModel.fromJson(feedbackData);
          } else {
            throw FormatException('Unexpected feedback format: $feedbackData');
          }
        } else {
          // Feedback not ready yet
          throw const FeedbackProcessingException(
            message:
                'Feedback is still being generated. Please try again in a moment.',
          );
        }
      } else {
        throw ServerException(
          message:
              'Failed to get feedback: ${response.statusCode} - ${response.body}',
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
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.conversationsEndpoint}/$id'),
        headers: ApiConstants.authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return ConversationModel.fromJson(responseData);
      } else {
        throw ServerException(
          message:
              'Failed to get conversation: ${response.statusCode} - ${response.body}',
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
