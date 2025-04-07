/// 💬 **Conversation Entity**
///
/// Represents a conversation scenario between user and AI.
class ConversationEntity {
  /// 👤 User's role in the conversation
  final String userRole;

  /// 🤖 AI's role in the conversation
  final String aiRole;

  /// 📝 Conversation situation/context
  final String situation;

  /// 🔹 Constructor
  const ConversationEntity({
    required this.userRole,
    required this.aiRole,
    required this.situation,
  });

  /// 📥 Create from JSON
  factory ConversationEntity.fromJson(Map<String, dynamic> json) =>
      ConversationEntity(
        userRole: json['user_role'],
        aiRole: json['ai_role'],
        situation: json['situation'],
      );

  /// 📤 Convert to JSON
  Map<String, dynamic> toJson() => {
        'user_role': userRole,
        'ai_role': aiRole,
        'situation': situation,
      };
}
