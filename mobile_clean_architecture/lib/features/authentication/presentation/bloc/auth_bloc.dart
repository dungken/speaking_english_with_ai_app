import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Authentication bloc that handles user authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
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
      final result = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message ?? 'Sign in failed')),
        (user) {
          // Set the API token for requests
          ApiConstants.token = user.token;
          emit(Authenticated(user));
        },
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
      final result = await authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message ?? 'Registration failed')),
        (user) {
          // Set the API token for requests
          ApiConstants.token = user.token;
          emit(Authenticated(user));
        },
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
      final result = await authRepository.signOut();

      result.fold(
        (failure) => emit(AuthError(failure.message ?? 'Sign out failed')),
        (_) {
          // Clear the API token
          ApiConstants.token = '';
          emit(Unauthenticated());
        },
      );
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
      // Check if the user is authenticated
      final isAuthenticated = await authRepository.isAuthenticated();

      if (isAuthenticated) {
        // Get the current user
        final result = await authRepository.getCurrentUser();

        result.fold(
          (failure) => emit(Unauthenticated()),
          (user) {
            // Set the API token for requests
            ApiConstants.token = user.token;
            emit(Authenticated(user));
          },
        );
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }
}
