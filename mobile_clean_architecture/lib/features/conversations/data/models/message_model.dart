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
    // Handle timestamp parsing safely
    DateTime timestamp;
    try {
      timestamp = json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now();
    } catch (e) {
      print('Error parsing message timestamp: $e');
      timestamp = DateTime.now();
    }

    final String senderId =
        json['_id']?.toString() ?? json['id']?.toString() ?? '';

    final String convId = json['conversation_id']?.toString() ?? '';

    // Determine sender type safely
    final senderString = json['sender']?.toString().toLowerCase() ?? 'ai';
    final senderType = senderString == 'user' ? SenderType.user : SenderType.ai;

    return MessageModel(
      id: senderId,
      conversationId: convId,
      sender: senderType,
      content: json['content']?.toString() ?? '',
      timestamp: timestamp,
      audioPath: json['audio_path']?.toString(),
      transcription: json['transcription']?.toString(),
      feedbackId: json['feedback_id']?.toString(),
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
