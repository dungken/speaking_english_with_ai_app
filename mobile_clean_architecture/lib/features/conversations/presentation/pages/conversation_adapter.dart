import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/audio_services.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_event_adapter.dart';
import 'conversation_page.dart';
import 'conversations_list_page.dart';

/// Adapter class to handle the transition between different conversation implementations
class ConversationAdapter {
  static final GetIt getIt = GetIt.instance;

  /// Initialize the adapter
  static void init() {
    if (!getIt.isRegistered<AudioService>()) {
      getIt.registerLazySingleton<AudioService>(() => AudioService());
    }
  }

  /// Navigate to the conversation detail page
  static void navigateToConversation(BuildContext context,
      Conversation conversation, Message? initialMessage) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConversationPage(
          conversation: conversation,
          initialMessage: initialMessage,
        ),
      ),
    );
  }

  /// Navigate to the conversations list page
  static void navigateToConversationsList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ConversationsListPage(),
      ),
    );
  }

  /// Process audio and send a message
  static Future<void> processAudioAndSendMessage(
    BuildContext context,
    String conversationId,
    String audioPath,
  ) async {
    try {
      final AudioService audioService = getIt<AudioService>();

      // Upload the audio and get transcription
      final response =
          await audioService.uploadAudioAndGetTranscription(audioPath);

      // Get the audio ID from the response
      final audioId = response['audio_id'] as String;

      // Send the speech message
      context.read<ConversationBloc>().add(
            SendSpeechMessageEvent(
              conversationId: conversationId,
              audioId: audioId,
            ),
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing audio: ${e.toString()}')),
      );
    }
  }

  /// Load a conversation
  static void loadConversation(BuildContext context) {
    context.read<ConversationBloc>().add(
          GetUserConversationsEvent(),
        );
  }

  /// Get feedback for a message
  static void getFeedback(BuildContext context, String messageId) {
    context.read<ConversationBloc>().add(
          GetMessageFeedbackEvent(messageId: messageId),
        );
  }
}
