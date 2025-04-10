import 'dart:developer' as developer;

class Logger {
  static void i(String tag, String message) {
    developer.log('ℹ️ INFO: $message', name: tag);
  }

  static void e(String tag, String message, [dynamic error]) {
    developer.log('❌ ERROR: $message${error != null ? '\nError: $error' : ''}',
        name: tag, error: error);
  }

  static void s(String tag, String message) {
    developer.log('✅ SUCCESS: $message', name: tag);
  }

  static void api(String method, String endpoint,
      {dynamic body, dynamic response, dynamic error}) {
    final tag = '🌐 API';
    final methodColor = _getMethodColor(method);

    developer.log(
      '''
$methodColor $method $endpoint
${body != null ? '📦 Request: $body' : ''}
${response != null ? '📩 Response: $response' : ''}
${error != null ? '❌ Error: $error' : ''}
''',
      name: tag,
    );
  }

  static String _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return '🟢'; // Green for GET
      case 'POST':
        return '🟡'; // Yellow for POST
      case 'PUT':
        return '🟣'; // Purple for PUT
      case 'DELETE':
        return '🔴'; // Red for DELETE
      default:
        return '⚪️'; // White for others
    }
  }
}
