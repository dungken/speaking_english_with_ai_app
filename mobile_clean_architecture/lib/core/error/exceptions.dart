/// Base Exception class for the application
class AppException implements Exception {
  final String message;

  AppException({required this.message});

  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when a server error occurs
class ServerException extends AppException {
  final int statusCode;

  ServerException({required String message, required this.statusCode})
    : super(message: message);

  @override
  String toString() => 'ServerException: $message (Status code: $statusCode)';
}

/// Exception thrown when a cache error occurs
class CacheException extends AppException {
  CacheException({required String message}) : super(message: message);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when a network error occurs
class NetworkException extends AppException {
  NetworkException({required String message}) : super(message: message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when an authentication error occurs
class AuthException extends AppException {
  AuthException({required String message}) : super(message: message);

  @override
  String toString() => 'AuthException: $message';
}
