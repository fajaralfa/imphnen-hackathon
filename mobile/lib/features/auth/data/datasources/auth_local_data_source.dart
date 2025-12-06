import 'dart:convert';

import 'package:imphenhackaton/core/error/exceptions.dart';
import 'package:imphenhackaton/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for caching user data.
abstract class AuthLocalDataSource {
  /// Get cached user from local storage.
  Future<UserModel?> getCachedUser();

  /// Cache user to local storage.
  Future<void> cacheUser(UserModel user);

  /// Clear cached user from local storage.
  Future<void> clearCache();

  /// Check if user is cached.
  Future<bool> hasCache();

  Future<bool> isTokenExpired();
}

/// Implementation using SharedPreferences.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  static const String _cachedUserKey = 'CACHED_USER';

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = _sharedPreferences.getString(_cachedUserKey);
      if (jsonString == null) return null;
      return UserModel.fromJsonString(jsonString);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _sharedPreferences.setString(_cachedUserKey, user.toJsonString());
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _sharedPreferences.remove(_cachedUserKey);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<bool> hasCache() async {
    return _sharedPreferences.containsKey(_cachedUserKey);
  }

  @override
  Future<bool> isTokenExpired() async {
    try {
      final user = await getCachedUser();
      if (user == null || user.token == null) {
        return true;
      }
      final parts = user.token!.split('.');
      if (parts.length != 3) return true;

      final payload = _decodeBase64(parts[1]);
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final exp = data['exp'] as int?;

      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

      return DateTime.now()
          .isAfter(expiryDate.subtract(const Duration(seconds: 5)));
    } catch (e) {
      return true;
    }
  }

  String _decodeBase64(String str) {
    var output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 1:
        output += '===';
      case 2:
        output += '==';
      case 3:
        output += '=';
    }
    return utf8.decode(base64Url.decode(output));
  }
}
