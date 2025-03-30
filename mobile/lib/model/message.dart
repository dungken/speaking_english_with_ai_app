/// 📩 **Message Model**
///
/// This class represents a chat message in the system.
///
/// Each message consists of:
/// - `msg`: The actual text content of the message.
/// - `msgType`: Defines whether the message is from the user or the bot.
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
