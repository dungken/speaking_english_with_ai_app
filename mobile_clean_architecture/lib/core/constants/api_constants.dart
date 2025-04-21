/// API constants used throughout the application
class ApiConstants {
  /// Base URL for API requests
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// Authentication endpoints
  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';

  /// Authentication token
  /// In a real app, this would be stored securely and retrieved dynamically
  static String token = '';

  /// Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  /// Default timeout duration in seconds
  static const int timeoutDuration = 30;
}
