import 'package:appwrite/appwrite.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Client _client;
  final Account _account;

  AuthRepositoryImpl()
      : _client = Client()
          ..setEndpoint('YOUR_APPWRITE_ENDPOINT')
          ..setProject('YOUR_PROJECT_ID'),
        _account = Account(Client()
          ..setEndpoint('YOUR_APPWRITE_ENDPOINT')
          ..setProject('YOUR_PROJECT_ID'));

  @override
  Future<UserEntity> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      final user = await _account.get();
      return UserEntity(
        id: user.$id,
        email: user.email,
        name: user.name,
        photoUrl: null, // Appwrite doesn't have a built-in photo URL
        createdAt: DateTime.parse(user.$createdAt),
        lastLoginAt: DateTime.now(),
      );
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
      return UserEntity(
        id: user.$id,
        email: user.email,
        name: user.name,
        photoUrl: null,
        createdAt: DateTime.parse(user.$createdAt),
        lastLoginAt: null,
      );
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _account.createRecovery(
        email: email,
        url: 'YOUR_PASSWORD_RESET_URL',
      );
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = await _account.get();
      return UserEntity(
        id: user.$id,
        email: user.email,
        name: user.name,
        photoUrl: null,
        createdAt: DateTime.parse(user.$createdAt),
        lastLoginAt: null,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity> updateProfile({String? name, String? photoUrl}) async {
    try {
      final user = await _account.updateName(name: name ?? '');
      return UserEntity(
        id: user.$id,
        email: user.email,
        name: user.name,
        photoUrl: photoUrl,
        createdAt: DateTime.parse(user.$createdAt),
        lastLoginAt: null,
      );
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }
}
