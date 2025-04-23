import 'conversation_event.dart';

/// This adapter class helps transition from the old event system to the new one
/// It converts old-style events to our new API-compatible events
class ConversationEventAdapter {
  /// Convert to LoadConversationEvent
  static LoadConversationEvent adaptLoadConversation({
    required String conversationId,
  }) {
    return LoadConversationEvent(
      conversationId: conversationId,
    );
  }
  
  /// Convert SendUserMessageEvent to SendSpeechMessageEvent
  /// Note: This requires first uploading the audio to get an audioId
  static SendSpeechMessageEvent adaptSendUserMessage({
    required String conversationId,
    required String audioId,
  }) {
    return SendSpeechMessageEvent(
      conversationId: conversationId,
      audioId: audioId,
    );
  }
  
  /// Convert RequestFeedbackEvent to GetMessageFeedbackEvent
  static GetMessageFeedbackEvent adaptRequestFeedback({
    required String messageId,
  }) {
    return GetMessageFeedbackEvent(
      messageId: messageId,
    );
  }
  
  /// StopRecordingEvent adapter - now includes transcription parameter
  static StopRecordingEvent adaptStopRecording({
    required String filePath,
    String? transcription,
  }) {
    return StopRecordingEvent(
      filePath: filePath,
      transcription: transcription,
    );
  }
  
  /// Upload audio for transcription
  static UploadAudioEvent adaptUploadAudio({
    required String filePath,
  }) {
    return UploadAudioEvent(
      filePath: filePath,
    );
  }
  
  /// Create a new conversation
  static CreateConversationEvent adaptCreateConversation({
    required String userRole,
    required String aiRole,
    required String situation,
  }) {
    return CreateConversationEvent(
      userRole: userRole,
      aiRole: aiRole,
      situation: situation,
    );
  }
  
  /// Edit transcription before sending
  static EditTranscriptionEvent adaptEditTranscription({
    required String transcription,
  }) {
    return EditTranscriptionEvent(
      transcription: transcription,
    );
  }
  
  /// Get user conversations
  static GetUserConversationsEvent adaptGetUserConversations({
    int page = 1,
    int limit = 10,
  }) {
    return GetUserConversationsEvent(
      page: page,
      limit: limit,
    );
  }
  
  /// Audio uploaded successfully
  static AudioUploadedEvent adaptAudioUploaded({
    required String audioId,
    required String transcription,
  }) {
    return AudioUploadedEvent(
      audioId: audioId,
      transcription: transcription,
    );
  }
}
