import 'dart:convert';
import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Interface for authentication local data source
abstract class AuthLocalDataSource {
  /// Cache the authenticated user
  Future<void> cacheUser(UserModel user);

  /// Get the cached authenticated user
  Future<UserModel> getLastUser();

  /// Clear the cached authenticated user
  Future<void> clearUser();

  /// Check if a user is cached
  Future<bool> hasUser();
}

/// Implementation of authentication local data source using Hive
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box box;

  static const String userKey = 'CACHED_USER';

  AuthLocalDataSourceImpl({required this.box});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await box.put(userKey, jsonEncode(user.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getLastUser() async {
    try {
      final jsonString = box.get(userKey);
      if (jsonString != null) {
        return UserModel.fromJson(jsonDecode(jsonString));
      } else {
        throw CacheException(message: 'No cached user found');
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to get cached user: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await box.delete(userKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear cached user: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasUser() async {
    try {
      final jsonString = box.get(userKey);
      return jsonString != null;
    } catch (e) {
      return false;
    }
  }
}
