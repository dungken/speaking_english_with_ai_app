import 'package:hive/hive.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// Model class for User, used for JSON serialization/deserialization
@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? profileImageUrl;

  @HiveField(4)
  final String token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.token,
  });

  /// Create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('Debug Parsing JSON: $json');

    // Handle both direct and nested response
    final user = json['user'] ?? json;

    // Check if the JSON contains only authentication fields
    if (json.containsKey('access_token') && json.containsKey('token_type')) {
      return UserModel(
        id: '', // No ID in authentication response
        name: '', // No name in authentication response
        email: '', // No email in authentication response
        profileImageUrl: null, // No profile image in authentication response
        token: json['access_token']?.toString() ?? '',
      );
    }

    // Safely extract values with proper null handling
    return UserModel(
      id: (user['_id'] ?? user['id'])?.toString() ?? '',
      name: user['name']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      profileImageUrl: user['avatar_url']?.toString(),
      token:
          json['access_token']?.toString() ?? user['token']?.toString() ?? '',
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'token': token,
    };
  }

  /// Create a UserModel from a User entity
  factory UserModel.fromUser(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      profileImageUrl: user.profileImageUrl,
      token: user.token,
    );
  }

  /// Convert to User entity
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      token: token,
    );
  }
}

class UserAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      id: reader.read(),
      name: reader.read(),
      email: reader.read(),
      profileImageUrl: reader.read(),
      token: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.email);
    writer.write(obj.profileImageUrl);
    writer.write(obj.token);
  }
}
