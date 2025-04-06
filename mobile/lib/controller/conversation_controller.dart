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

  void _initializeFakeConversation(String conversationId) {
    final now = DateTime.now();
    messages.addAll([
      MessageResponse(
        id: '1',
        conversationId: conversationId,
        text:
            'Hello! Welcome to our company. I\'m excited to learn more about your experience and skills. Can you tell me about a challenging project you worked on and how you handled it?',
        role: 'ai',
        audioUrl: 'mock_audio_url',
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      MessageResponse(
        id: '2',
        conversationId: conversationId,
        text:
            'Thank you for having me. In my recent project, I developed a real-time data processing system that handled large volumes of user analytics. The main challenge was optimizing performance while maintaining data accuracy.',
        role: 'user',
        audioUrl: null,
        createdAt: now.subtract(const Duration(minutes: 4)),
      ),
      MessageResponse(
        id: '3',
        conversationId: conversationId,
        text:
            'That\'s interesting! How did you approach the performance optimization? What specific techniques or tools did you use?',
        role: 'ai',
        audioUrl: 'mock_audio_url',
        createdAt: now.subtract(const Duration(minutes: 3)),
      ),
      MessageResponse(
        id: '4',
        conversationId: conversationId,
        text:
            'I implemented a combination of caching strategies and batch processing. Used Redis for hot data and designed a queue system for batch operations. This reduced the processing time by 60%.',
        role: 'user',
        audioUrl: null,
        createdAt: now.subtract(const Duration(minutes: 2)),
      ),
      MessageResponse(
        id: '5',
        conversationId: conversationId,
        text:
            'Excellent approach! I see you have experience with caching and distributed systems. How do you handle potential cache invalidation issues?',
        role: 'ai',
        audioUrl: 'mock_audio_url',
        createdAt: now.subtract(const Duration(minutes: 1)),
      ),
    ]);
  }

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

      final conversationId = '123';
      _initializeFakeConversation(conversationId);

      // Navigate to conversation screen
      Get.to(
          () => ConversationScreen(
                conversationId: conversationId,
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
        text:
            'That\'s a great point! Could you elaborate more on how you would ensure scalability and maintainability in such scenarios?',
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
