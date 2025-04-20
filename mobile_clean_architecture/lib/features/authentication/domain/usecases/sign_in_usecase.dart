/*
File: sign_in_usecase.dart
What this file does:
This file contains the business logic for signing in a user.
It takes email and password, validates them, and works with the auth repository
to sign in the user. It's a single-purpose use case following clean architecture.

How it relates to other files:
- Uses auth_repository.dart to perform the actual sign in
- Returns a User entity on success
- Used by auth_bloc.dart when handling sign in events
- Works with core/usecases/usecase.dart base class
- Parameters are defined in SignInParams class used by the UI

This is a domain use case that coordinates the sign in flow.
*/

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in a user with email and password
class SignInUseCase implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters for the sign in use case
class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
