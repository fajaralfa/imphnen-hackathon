import 'package:equatable/equatable.dart';

/// Entity representing an authenticated user.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.token,
  });

  /// Unique identifier from Google
  final String id;

  /// User's email address
  final String email;

  /// User's display name
  final String? displayName;

  /// URL to user's profile photo
  final String? photoUrl;

  /// Google ID token for API authentication
  final String? token;

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? token,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, token];
}
