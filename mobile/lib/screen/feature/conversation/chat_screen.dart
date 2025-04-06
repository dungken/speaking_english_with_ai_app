import 'package:flutter/material.dart';
import '../../../apis/conversation_api.dart';

class ChatScreen extends StatelessWidget {
  final String conversationId;
  final String token;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Center(
        child: Text('Chat Screen - Conversation ID: $conversationId'),
      ),
    );
  }
}
