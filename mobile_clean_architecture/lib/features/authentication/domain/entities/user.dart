/*
File: user.dart
What this file does:
This file defines the User entity, which is the core user model for our app.
It represents what a user is in our system, containing basic user information
like ID, name, email, and profile picture.

How it relates to other files:
- Used by auth_repository.dart for user authentication operations
- Used by sign_in_usecase.dart and register_usecase.dart when processing user login/registration
- Used by profile feature to display user information
- Used throughout the app wherever user data is needed

This is a domain entity, so it's independent of any database or API implementation.
*/

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
