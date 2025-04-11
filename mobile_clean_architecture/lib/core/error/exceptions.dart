/// Base class for all exceptions in the application
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() =>
      'AppException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Represents a server-side exception
class ServerException extends AppException {
  ServerException({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

/// Represents a cache/local storage exception
class CacheException extends AppException {
  CacheException({required String message}) : super(message: message);
}

/// Represents a network connectivity exception
class NetworkException extends AppException {
  NetworkException({required String message}) : super(message: message);
}
