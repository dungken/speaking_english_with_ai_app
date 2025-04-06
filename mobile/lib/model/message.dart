/// 📩 **Message Model**
///
/// This class represents a chat message in the system.
///
/// Each message consists of:
/// - `msg`: The actual text content of the message.
/// - `msgType`: Defines whether the message is from the user or the bot.
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class MessageCreate {
  final String text;
  final String? audioUrl;

  MessageCreate({
    required this.text,
    this.audioUrl,
  });

  Map<String, dynamic> toJson() => _$MessageCreateToJson(this);
  factory MessageCreate.fromJson(Map<String, dynamic> json) =>
      _$MessageCreateFromJson(json);
}

@JsonSerializable()
class MessageResponse {
  final String id;
  final String conversationId;
  final String role;
  final String text;
  final String? audioUrl;
  final Map<String, dynamic>? feedback;
  final DateTime createdAt;

  MessageResponse({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.text,
    this.audioUrl,
    this.feedback,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);
}

class Message {
  /// 📝 **Message Content**
  ///
  /// The text of the message.
  String msg;

  /// 🎭 **Message Type**
  ///
  /// Indicates whether the message is from the `user` or the `bot`.
  final MessageType msgType;

  /// 🔹 **Constructor**
  ///
  /// - `msg`: Required parameter for the message text.
  /// - `msgType`: Required parameter to specify the sender type.
  Message({required this.msg, required this.msgType});
}

/// 🎭 **Message Type Enum**
///
/// Represents the sender of a message.
/// - `user`: A message sent by the user.
/// - `bot`: A message sent by the AI bot.
enum MessageType { user, bot }
