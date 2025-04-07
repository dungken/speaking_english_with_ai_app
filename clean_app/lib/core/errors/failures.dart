/// Base class for all failures in the app
abstract class Failure {
  final String message;
  final String? code;

  Failure({required this.message, this.code});
}

/// Server failure
class ServerFailure extends Failure {
  ServerFailure({required String message, String? code})
      : super(message: message, code: code);
}

/// Cache failure
class CacheFailure extends Failure {
  CacheFailure({required String message, String? code})
      : super(message: message, code: code);
}

/// Network failure
class NetworkFailure extends Failure {
  NetworkFailure({required String message, String? code})
      : super(message: message, code: code);
}

/// Authentication failure
class AuthFailure extends Failure {
  AuthFailure({required String message, String? code})
      : super(message: message, code: code);
}

/// Validation failure
class ValidationFailure extends Failure {
  ValidationFailure({required String message, String? code})
      : super(message: message, code: code);
}
