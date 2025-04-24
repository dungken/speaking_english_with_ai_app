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
    // Handle messages field - could be null or missing in initial conversation
    List<Message> messagesList = [];
    if (json.containsKey('messages') && json['messages'] != null) {
      final messageData = json['messages'];
      if (messageData is List) {
        messagesList = messageData
            .map((message) => MessageModel.fromJson(message))
            .toList();
      }
    }

    // Parse dates safely
    DateTime? startedAt;
    try {
      startedAt = json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : DateTime.now();
    } catch (e) {
      print('Error parsing started_at date: $e');
      startedAt = DateTime.now();
    }

    DateTime? endedAt;
    if (json['ended_at'] != null) {
      try {
        endedAt = DateTime.parse(json['ended_at']);
      } catch (e) {
        print('Error parsing ended_at date: $e');
      }
    }

    return ConversationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userRole: json['user_role'] ?? '',
      aiRole: json['ai_role'] ?? '',
      situation: json['situation'] ?? '',
      messages: messagesList,
      startedAt: startedAt,
      endedAt: endedAt,
    );
  }

  /// Converts this model to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_role': userRole,
      'ai_role': aiRole,
      'situation': situation,
      'messages': messages.map((message) {
        if (message is MessageModel) {
          return message.toJson();
        }
        return {}; // Return empty object if not a MessageModel
      }).toList(),
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }
}
