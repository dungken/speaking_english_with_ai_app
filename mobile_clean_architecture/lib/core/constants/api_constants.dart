/// API constants used throughout the application
class ApiConstants {
  /// Base URL for API requests
  // Local backend URL (commented out)
  // static const String baseUrl = 'http://10.0.2.2:8000';

  // Production URL - using the deployed API
  static const String baseUrl = 'http://192.168.1.9:8000';

  /// Authentication endpoints
  static const String loginEndpoint = '/api/users/login';
  static const String registerEndpoint = '/api/users/register';

  /// Conversation endpoints
  static const String conversationsEndpoint = '/api/conversations';
  static const String messageEndpoint =
      '/api/conversations/{conversation_id}/message';
  static const String feedbackEndpoint = '/api/messages/{message_id}/feedback';

  /// Audio processing endpoint
  static const String audioToTextEndpoint = '/api/audio2text';

  /// Authentication token
  /// In a real app, this would be stored securely and retrieved dynamically
  static String token = '';

  /// Headers
  static Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// Default timeout duration in seconds
  static const int timeoutDuration = 30;
}
