import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String? message;

  const Failure({this.message});

  @override
  List<Object?> get props => [message];
}

/// Represents a server-side failure
class ServerFailure extends Failure {
  const ServerFailure({String? message}) : super(message: message);
}

/// Represents a cache/local storage failure
class CacheFailure extends Failure {
  const CacheFailure({String? message}) : super(message: message);
}

/// Represents a network connectivity failure
class NetworkFailure extends Failure {
  const NetworkFailure({String? message}) : super(message: message);
}

/// Represents a processing in progress status
class ProcessingFailure extends Failure {
  const ProcessingFailure({String? message}) : super(message: message);
}

/// Represents a validation failure (invalid user input)
class ValidationFailure extends Failure {
  const ValidationFailure({String? message}) : super(message: message);
}
