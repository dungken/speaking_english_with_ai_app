import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/conversation_repository.dart';
import 'conversation_state.dart';

/// This adapter class helps maintain compatibility with existing UI code
/// during the transition to the new API-based implementation
class ConversationStateAdapter {
  /// Get transcription from state for UI display
  static String? getTranscriptionFromState(ConversationState state) {
    // First check if there's a transcription directly in the state
    if (state.transcription != null && state.transcription!.isNotEmpty) {
      return state.transcription;
    }

    // If not, check if we have lastMessages and extract from user message
    if (state.lastMessages != null) {
      return state.lastMessages!.userMessage.content;
    }

    return null;
  }

  /// Get audio ID from state (for API calls)
  static String? getAudioIdFromState(ConversationState state) {
    return state.audioId;
  }

  /// Transform ConversationMessages to a list of messages for UI display
  static List<Message> getMessagesFromState(ConversationState state) {
    List<Message> messages = [];

    // First add existing messages from the conversation if available
    if (state.conversation != null && state.conversation!.messages.isNotEmpty) {
      messages.addAll(state.conversation!.messages);
    }

    // Then add the latest messages if they're not already in the list
    if (state.lastMessages != null) {
      final userMessage = state.lastMessages!.userMessage;
      final aiMessage = state.lastMessages!.aiMessage;

      // Only add if they're not already in the list
      if (!messages.any((m) => m.id == userMessage.id)) {
        messages.add(userMessage);
      }

      if (!messages.any((m) => m.id == aiMessage.id)) {
        messages.add(aiMessage);
      }
    }

    // Sort messages by timestamp
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return messages;
  }

  /// Update the conversation with the latest messages
  static Conversation? updateConversationWithMessages(ConversationState state) {
    if (state.conversation == null) return null;

    final updatedMessages = getMessagesFromState(state);

    return Conversation(
      id: state.conversation!.id,
      userRole: state.conversation!.userRole,
      aiRole: state.conversation!.aiRole,
      situation: state.conversation!.situation,
      messages: updatedMessages,
      startedAt: state.conversation!.startedAt,
      endedAt: state.conversation!.endedAt,
    );
  }

  /// Check if the state indicates recording is in progress
  static bool isRecording(ConversationState state) {
    return state.recordingState == RecordingState.recording;
  }

  /// Check if the state indicates audio processing is in progress
  static bool isProcessing(ConversationState state) {
    return state.recordingState == RecordingState.processing;
  }

  /// Check if the state indicates transcription is ready
  static bool isTranscriptionReady(ConversationState state) {
    return state.recordingState == RecordingState.transcribed &&
        state.transcription != null &&
        state.transcription!.isNotEmpty;
  }

  /// Check if the transcription was successful
  static bool isTranscriptionSuccessful(ConversationState state) {
    return state.transcriptionSuccess ??
        false; // Default to true for backward compatibility
  }

  /// Get the recording path from state
  static String? getRecordingPath(ConversationState state) {
    return state.lastRecordingPath;
  }

  /// Check if the state indicates loading
  static bool isLoading(ConversationState state) {
    return state.isLoading;
  }

  /// Get error message from state
  static String? getErrorMessage(ConversationState state) {
    return state.errorMessage;
  }
}
