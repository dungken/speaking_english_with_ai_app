import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested(this.name, this.email, this.password);

  @override
  List<Object> get props => [name, email, password];
}

class SignOutRequested extends AuthEvent {}

class GetCurrentUserRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Implement actual sign in logic
      await Future.delayed(const Duration(seconds: 1));
      emit(
        Authenticated(
          const User(
            id: '1',
            name: 'Test User',
            email: 'test@example.com',
            profileImageUrl: null,
            token: 'test_token',
          ),
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Implement actual registration logic
      await Future.delayed(const Duration(seconds: 1));
      emit(
        Authenticated(
          User(
            id: '1',
            name: event.name,
            email: event.email,
            profileImageUrl: null,
            token: 'test_token',
          ),
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Implement actual sign out logic
      await Future.delayed(const Duration(milliseconds: 500));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Implement actual get current user logic
      await Future.delayed(const Duration(milliseconds: 500));
      emit(
        Authenticated(
          const User(
            id: '1',
            name: 'Test User',
            email: 'test@example.com',
            profileImageUrl: null,
            token: 'test_token',
          ),
        ),
      );
    } catch (e) {
      emit(Unauthenticated());
    }
  }
}
