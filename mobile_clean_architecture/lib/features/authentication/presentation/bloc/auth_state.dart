part of 'auth_bloc.dart';

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

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// State when the user is not authenticated
class Unauthenticated extends AuthState {}

/// State when there's an error in authentication
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when authentication is successful
class AuthSuccess extends AuthState {}

/// State when authentication fails
class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}
