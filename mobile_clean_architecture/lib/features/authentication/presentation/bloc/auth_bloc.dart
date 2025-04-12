import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Authentication bloc that handles user authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignInEvent>(_onSignInRequested);
    on<RegisterEvent>(_onRegisterRequested);
    on<SignOutEvent>(_onSignOutRequested);
    on<CheckAuthenticationEvent>(_onGetCurrentUserRequested);
  }

  Future<void> _onSignInRequested(
    SignInEvent event,
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
    RegisterEvent event,
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
    SignOutEvent event,
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
    CheckAuthenticationEvent event,
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
