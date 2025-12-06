import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:imphenhackaton/core/error/exceptions.dart';
import 'package:imphenhackaton/features/auth/data/models/user_model.dart';

/// Remote data source for Google Sign-In operations.
abstract class AuthRemoteDataSource {
  /// Sign in with Google, verify with backend, and return user with JWT token.
  Future<UserModel> signInWithGoogle();

  // Future<UserModel> checkToken();

  /// Sign out from Google.
  Future<void> signOut();
}

/// Implementation using google_sign_in package and backend API.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required GoogleSignIn googleSignIn,
    required http.Client httpClient,
  })  : _googleSignIn = googleSignIn,
        _httpClient = httpClient;

  final GoogleSignIn _googleSignIn;
  final http.Client _httpClient;

  // Get base URL from .env file
  static String get _apiBaseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw const ServerException('BASE_URL not configured in .env');
    }
    return url;
  }
  // static const String _apiBaseUrl = 'http://192.168.18.17:8000/api';

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Step 1: Sign in with Google
      final account = await _googleSignIn.signIn();

      if (account == null) {
        throw const ServerException('Sign in cancelled');
      }

      print('Google account ID: ${account.id}');
      print('Google account email: ${account.email}');
      print('Google account name: ${account.displayName}');
      print('Google account photo URL: ${account.photoUrl}');

      // Step 2: Get the Google ID token
      final authentication = await account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null) {
        throw const ServerException('Failed to get Google ID token');
      }

      // print('Google ID token: $idToken');

      // Step 3: Send ID token to backend for verification
      print('Sending token to backend: $_apiBaseUrl/auth/mobile/google');

      final response = await _httpClient.post(
        Uri.parse('$_apiBaseUrl/auth/mobile/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      // print('Backend response status: ${response.statusCode}');
      // print('Backend response body: ${response.body}');

      if (response.statusCode != 200) {
        throw ServerException(
          'Backend authentication failed: ${response.body}',
        );
      }

      // Step 4: Parse response and get JWT token from backend
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final jwtToken = data['access_token'] as String?;

      if (jwtToken == null) {
        throw const ServerException('No access token in response');
      }

      return UserModel(
        id: account.id,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
        token: jwtToken, // This is now the JWT from your backend
      );
    } catch (e, stackTrace) {
      print('=== AUTH ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // @override
  // Future<UserModel> checkToken(String idToken) async {
  //   try {
  //     final response = await _httpClient.post(
  //       Uri.parse('$_apiBaseUrl/auth/mobile/google'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'id_token': idToken}),
  //     );

  //     if (response.statusCode != 200) {
  //       throw const ServerException(
  //         'Authentication failed',
  //       );
  //     }
  //   } catch (e) {}
  // }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
