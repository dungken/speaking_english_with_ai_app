// lib/controller/conversation_controller.dart

import 'package:get/get.dart';
import '../model/message.dart';
import '../screen/feature/conversation/conversation_screen.dart';

/// 🎮 **Conversation Controller**
///
/// Manages conversation state and business logic.
class ConversationController extends GetxController {
  final String token;

  // Observable states
  final isLoading = false.obs;
  final messages = <MessageResponse>[].obs;
  final error = Rx<String?>(null);

  ConversationController({required this.token});

  /// 📝 Create a new conversation
  Future<void> createConversation(
    String userRole,
    String aiRole,
    String situation,
  ) async {
    try {
      isLoading.value = true;
      error.value = null;

      // Mock response for UI testing
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to conversation screen
      Get.to(
          () => ConversationScreen(
                conversationId: '123',
                token: token,
              ),
          arguments: {
            'situation': situation,
          });
    } catch (e) {
      error.value = 'Failed to create conversation: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// 💬 Send a message
  Future<void> sendMessage(String conversationId, String text) async {
    try {
      // Mock message response
      final mockMessage = MessageResponse(
        id: DateTime.now().toString(),
        conversationId: conversationId,
        text: text,
        role: 'user',
        audioUrl: null,
        createdAt: DateTime.now(),
      );
      messages.add(mockMessage);

      // Mock AI response after delay
      await Future.delayed(const Duration(seconds: 1));
      final mockAiResponse = MessageResponse(
        id: DateTime.now().toString(),
        conversationId: conversationId,
        text: 'This is a mock AI response to: $text',
        role: 'ai',
        audioUrl: 'mock_audio_url',
        createdAt: DateTime.now(),
      );
      messages.add(mockAiResponse);
    } catch (e) {
      error.value = e.toString();
    }
  }
}
