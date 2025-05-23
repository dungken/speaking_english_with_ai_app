import '../data/services/speech_audio_service.dart';

/// Configures the SpeechAudioService with the appropriate API URL
/// and initializes any required resources.
///
/// Call this during app initialization to ensure the audio service
/// is properly configured before it's used.
void configureSpeechAudioService(String baseApiUrl) {
  // Configure the base URL for the audio streaming endpoint

  // Perform any additional setup like cache cleanup
  SpeechAudioService().cleanupCache();
}
