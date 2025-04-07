import '../entities/user_entity.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);

  /// Sign up with email and password
  Future<UserEntity> signUpWithEmailAndPassword(String email, String password);

  /// Reset password
  Future<void> resetPassword(String email);

  /// Sign out
  Future<void> signOut();

  /// Get current user
  Future<UserEntity?> getCurrentUser();

  /// Update user profile
  Future<UserEntity> updateProfile({
    String? name,
    String? photoUrl,
  });
}
