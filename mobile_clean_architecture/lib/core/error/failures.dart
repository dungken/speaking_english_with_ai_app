import 'package:equatable/equatable.dart';

/// Base failure class for the application
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Server failure when there's an issue with the server
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

/// Cache failure when there's an issue with local storage
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

/// Network failure when there's an issue with network connectivity
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

/// Authentication failure when there's an issue with authentication
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message: message);
}

/// Input validation failure when user input is invalid
class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message: message);
}
