import 'package:equatable/equatable.dart';

/// Enum representing who sent a message
enum SenderType {
  /// Message sent by the user
  user,
  
  /// Message sent by the AI
  ai,
}

/// Entity representing a message in a conversation
class Message extends Equatable {
  /// Unique identifier for the message
  final String id;
  
  /// ID of the conversation this message belongs to
  final String conversationId;
  
  /// Who sent this message
  final SenderType sender;
  
  /// The content of the message
  final String content;
  
  /// When the message was sent
  final DateTime timestamp;
  
  /// Path to the audio recording (if available)
  final String? audioPath;
  
  /// Transcription of the audio recording (if available)
  final String? transcription;
  
  /// ID of the associated feedback (if available)
  final String? feedbackId;

  const Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.audioPath,
    this.transcription,
    this.feedbackId,
  });

  @override
  List<Object?> get props => [
    id, 
    conversationId, 
    sender, 
    content, 
    timestamp, 
    audioPath, 
    transcription, 
    feedbackId,
  ];
}
