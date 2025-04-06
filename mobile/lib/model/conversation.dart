// lib/model/conversation.dart

import 'package:json_annotation/json_annotation.dart';

part 'conversation.g.dart';

/// 💬 **Conversation Model**
///
/// Represents a conversation scenario between user and AI.
@JsonSerializable()
class Conversation {
  /// 👤 User's role in the conversation
  final String userRole;

  /// 🤖 AI's role in the conversation
  final String aiRole;

  /// 📝 Conversation situation/context
  final String situation;

  /// 🔹 Constructor
  Conversation({
    required this.userRole,
    required this.aiRole,
    required this.situation,
  });

  /// 📥 Create from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

  /// 📤 Convert to JSON
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}

@JsonSerializable()
class ConversationCreate {
  final String userRole;
  final String aiRole;
  final String situation;

  ConversationCreate({
    required this.userRole,
    required this.aiRole,
    required this.situation,
  });

  Map<String, dynamic> toJson() => _$ConversationCreateToJson(this);
  factory ConversationCreate.fromJson(Map<String, dynamic> json) =>
      _$ConversationCreateFromJson(json);
}

@JsonSerializable()
class ConversationResponse {
  final String id;
  final String userId;
  final String topic;
  final String aiAssistant;
  final String situationDescription;
  final DateTime createdAt;
  final double? score;

  ConversationResponse({
    required this.id,
    required this.userId,
    required this.topic,
    required this.aiAssistant,
    required this.situationDescription,
    required this.createdAt,
    this.score,
  });

  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);
}