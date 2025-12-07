import 'dart:convert';

import 'package:imphenhackaton/features/auth/domain/entities/user_entity.dart';

/// Model for [UserEntity] with JSON serialization.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.token,
  });

  /// Create [UserModel] from JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      token: json['token'] as String?,
    );
  }

  /// Create [UserModel] from JSON string.
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);
  }

  /// Create [UserModel] from [UserEntity].
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      token: entity.token,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'token': token,
    };
  }

  /// Convert to JSON string.
  String toJsonString() {
    return json.encode(toJson());
  }
}
