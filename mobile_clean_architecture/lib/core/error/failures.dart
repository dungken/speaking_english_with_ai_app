import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Represents a server-side failure
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

/// Represents a cache/local storage failure
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

/// Represents a network connectivity failure
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}
