import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import 'message_model.dart';

/// Model class for Conversation data from the API
class ConversationModel extends Conversation {
  const ConversationModel({
    required String id,
    required String userRole,
    required String aiRole,
    required String situation,
    required List<Message> messages,
    required DateTime startedAt,
    DateTime? endedAt,
  }) : super(
          id: id,
          userRole: userRole,
          aiRole: aiRole,
          situation: situation,
          messages: messages,
          startedAt: startedAt,
          endedAt: endedAt,
        );

  /// Creates a ConversationModel from a JSON object
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['_id'] ?? json['id'],
      userRole: json['user_role'],
      aiRole: json['ai_role'],
      situation: json['situation'],
      messages: (json['messages'] as List)
          .map((message) => MessageModel.fromJson(message))
          .toList(),
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
    );
  }

  /// Converts this model to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_role': userRole,
      'ai_role': aiRole,
      'situation': situation,
      'messages': (messages as List<MessageModel>)
          .map((message) => (message as MessageModel).toJson())
          .toList(),
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }
}
