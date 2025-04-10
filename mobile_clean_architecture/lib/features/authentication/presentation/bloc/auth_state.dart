import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the authentication bloc
class AuthInitial extends AuthState {}

/// Loading state of the authentication bloc
class AuthLoading extends AuthState {}

/// State when the user is authenticated
class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object> get props => [user];
}

/// State when the user is not authenticated
class Unauthenticated extends AuthState {}

/// State when there's an error in authentication
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
