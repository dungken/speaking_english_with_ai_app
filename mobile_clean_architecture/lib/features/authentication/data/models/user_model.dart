import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// Model class for User, used for JSON serialization/deserialization
@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required String id,
    required String name,
    required String email,
    String? profileImageUrl,
    required String token,
  }) : super(
         id: id,
         name: name,
         email: email,
         profileImageUrl: profileImageUrl,
         token: token,
       );

  /// Create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

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
}
