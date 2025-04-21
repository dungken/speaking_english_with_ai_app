import '../../domain/entities/message.dart';

/// Model class for Message data from the API
class MessageModel extends Message {
  const MessageModel({
    required String id,
    required String conversationId,
    required SenderType sender,
    required String content,
    required DateTime timestamp,
    String? audioPath,
    String? transcription,
    String? feedbackId,
  }) : super(
          id: id,
          conversationId: conversationId,
          sender: sender,
          content: content,
          timestamp: timestamp,
          audioPath: audioPath,
          transcription: transcription,
          feedbackId: feedbackId,
        );

  /// Creates a MessageModel from a JSON object
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? json['id'],
      conversationId: json['conversation_id'],
      sender: json['sender'] == 'user' ? SenderType.user : SenderType.ai,
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      audioPath: json['audio_path'],
      transcription: json['transcription'],
      feedbackId: json['feedback_id'],
    );
  }

  /// Converts this model to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender': sender == SenderType.user ? 'user' : 'ai',
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'audio_path': audioPath,
      'transcription': transcription,
      'feedback_id': feedbackId,
    };
  }
}
