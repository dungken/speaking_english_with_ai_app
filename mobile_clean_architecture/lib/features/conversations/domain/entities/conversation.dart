import 'package:equatable/equatable.dart';
import 'message.dart';

/// Represents a conversation between the user and AI for role-play practice
///
/// A conversation contains metadata about the role-play scenario and 
/// a list of messages exchanged between participants.
class Conversation extends Equatable {
  /// Unique identifier for the conversation
  final String id;
  
  /// The role played by the user in this conversation
  final String userRole;
  
  /// The role played by the AI in this conversation
  final String aiRole;
  
  /// Detailed description of the situation/context
  final String situation;
  
  /// Messages exchanged in the conversation
  final List<Message> messages;
  
  /// When the conversation started
  final DateTime startedAt;
  
  /// When the conversation ended (null if ongoing)
  final DateTime? endedAt;

  const Conversation({
    required this.id,
    required this.userRole,
    required this.aiRole,
    required this.situation,
    required this.messages,
    required this.startedAt,
    this.endedAt,
  });

  /// Returns a copy of this Conversation with specified fields replaced
  Conversation copyWith({
    String? id,
    String? userRole,
    String? aiRole,
    String? situation,
    List<Message>? messages,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userRole: userRole ?? this.userRole,
      aiRole: aiRole ?? this.aiRole,
      situation: situation ?? this.situation,
      messages: messages ?? this.messages,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  /// Creates a formatted string representing the context of this conversation
  /// Used for AI prompting and context building
  String getFormattedContext() {
    return '''
    You are having a conversation with a language learner who is practicing English.
    
    Situation: $situation
    Your role: $aiRole
    User's role: $userRole
    
    Please respond to the user in natural, conversational English that's appropriate for the situation.
    Keep your responses helpful and encouraging, while staying in character.
    ''';
  }

  @override
  List<Object?> get props => [id, userRole, aiRole, situation, messages, startedAt, endedAt];
}
