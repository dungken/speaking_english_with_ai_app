// lib/controller/conversation_controller.dart

import 'package:get/get.dart';
import '../apis/conversation_api.dart';
import '../model/conversation.dart';
import '../model/message.dart';

/// 🎮 **Conversation Controller**
///
/// Manages conversation state and business logic.
class ConversationController extends GetxController {
  final ConversationApi _api = ConversationApi();
  
  // Observable states
  final isLoading = false.obs;
  final messages = <Message>[].obs;
  final error = Rx<String?>(null);

  /// 📝 Create a new conversation
  Future<void> createConversation(
    String userRole,
    String aiRole,
    String situation,
  ) async {
    try {
      isLoading.value = true;
      error.value = null;

      final conversation = Conversation(
        userRole: userRole,
        aiRole: aiRole,
        situation: situation,
      );

      final result = await _api.createConversation(conversation);
      
      // Handle the initial AI message
      if (result['initial_message'] != null) {
        messages.add(Message(
          msg: result['initial_message']['text'],
          msgType: MessageType.bot,
        ));
      }

      // Navigate to chat screen
      Get.toNamed('/chat', arguments: result['conversation']['id']);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 💬 Send a message
  Future<void> sendMessage(String conversationId, String message) async {
    try {
      // Add user message immediately
      messages.add(Message(msg: message, msgType: MessageType.user));

      final result = await _api.sendMessage(conversationId, message);
      
      // Add AI response
      messages.add(Message(
        msg: result['text'],
        msgType: MessageType.bot,
      ));
    } catch (e) {
      error.value = e.toString();
    }
  }
}