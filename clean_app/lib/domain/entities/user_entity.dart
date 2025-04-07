/// User entity representing a user in the system
class UserEntity {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Create from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        photoUrl: json['photo_url'],
        createdAt: DateTime.parse(json['created_at']),
        lastLoginAt: json['last_login_at'] != null
            ? DateTime.parse(json['last_login_at'])
            : null,
      );

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'photo_url': photoUrl,
        'created_at': createdAt.toIso8601String(),
        'last_login_at': lastLoginAt?.toIso8601String(),
      };
}
