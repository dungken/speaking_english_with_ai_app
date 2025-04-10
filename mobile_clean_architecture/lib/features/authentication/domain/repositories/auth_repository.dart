import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../../../../core/error/failures.dart';

/// Interface for the authentication repository
///
/// This defines the contract that any authentication implementation must fulfill
abstract class AuthRepository {
  /// Sign in a user with email and password
  ///
  /// Returns a [User] object if successful, or a [Failure] if not
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  /// Register a new user with name, email and password
  ///
  /// Returns a [User] object if successful, or a [Failure] if not
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Sign out the current user
  ///
  /// Returns true if successful, or a [Failure] if not
  Future<Either<Failure, bool>> signOut();

  /// Get the currently authenticated user
  ///
  /// Returns a [User] object if a user is authenticated, or a [Failure] if not
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if a user is currently authenticated
  ///
  /// Returns true if a user is authenticated, false otherwise
  Future<bool> isAuthenticated();
}
