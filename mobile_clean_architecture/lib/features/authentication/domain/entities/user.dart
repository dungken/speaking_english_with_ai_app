import 'package:equatable/equatable.dart';

/// User entity that represents a user in the system
///
/// This is a domain entity, which is independent of any data layer implementation
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String token; // Auth token for API requests

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.token,
  });

  @override
  List<Object?> get props => [id, name, email, profileImageUrl, token];
}
