/// API constants used throughout the application
class ApiConstants {
  /// Base URL for API requests
  // Local backend URL (commented out)
  // static const String baseUrl = 'http://10.0.2.2:8000';

  // chạy 2 lệnh trên cmd này kết nối với đt qua usb

// adb reverse tcp:8000 tcp:8000
// adb reverse tcp:8880 tcp:8880
  static const String ip = 'localhost';
  static const String baseUrl = 'http://$ip:8000';
  static const String ttsBaseUrl = 'http://$ip:8880';

  static const String loginEndpoint = '/api/users/login';
  static const String registerEndpoint = '/api/users/register';

  /// Conversation endpoints
  static const String conversationsEndpoint = '/api/conversations';
  static const String messageEndpoint =
      '/api/conversations/{conversation_id}/message';
  static const String feedbackEndpoint = '/api/messages/{message_id}/feedback';
  static const String speechEndpoint = '/api/messages/{message_id}/speech';
  static const String voice_context = '/messages/{message_id}/voice_context';

  /// Image practice endpoints
  static const String imagesBaseEndpoint = '/api/images';
  static const String imagesPracticeEndpoint = '/api/images/practice';
  static const String imageByIdEndpoint = '/api/images/{image_id}';
  static const String imageFeedbackEndpoint = '/api/images/feedback';

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
