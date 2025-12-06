import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:imphenhackaton/core/error/exceptions.dart';

/// Exception thrown when authentication fails (401 Unauthorized).
class AuthException implements Exception {
  const AuthException([this.message]);

  final String? message;

  @override
  String toString() => message ?? 'Authentication failed';
}

/// Remote data source for caption generation API.
abstract class GenerateCaptionRemoteDataSource {
  /// Generate caption for the given images.
  ///
  /// [images] - List of image files to upload
  /// [context] - Optional context/description for the images
  /// [authToken] - JWT token for authorization
  ///
  /// Throws [AuthException] if token is invalid (401).
  /// Throws [ServerException] for other server errors.
  Future<String> generateCaption({
    required List<File> images,
    required String authToken,
    String? context,
  });
}

class GenerateCaptionRemoteDataSourceImpl
    implements GenerateCaptionRemoteDataSource {
  GenerateCaptionRemoteDataSourceImpl();

  static const Duration _timeout = Duration(seconds: 90);

  // Get base URL from .env file
  static String get _apiBaseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw const ServerException('BASE_URL not configured in .env');
    }
    return url;
  }

  @override
  Future<String> generateCaption({
    required List<File> images,
    required String authToken,
    String? context,
  }) async {
    try {
      final uri = Uri.parse('$_apiBaseUrl/v1/caption/generate');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $authToken';

      // Add images as multipart files
      for (final image in images) {
        final fileName = image.path.split('/').last;
        final mimeType = _getMimeType(fileName);
        final multipartFile = await http.MultipartFile.fromPath(
          'images',
          image.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      // Add optional context field
      if (context != null && context.isNotEmpty) {
        request.fields['context'] = context;
      }

      print('=== GENERATE CAPTION REQUEST ===');
      print('URL: $uri');
      print('Images count: ${images.length}');
      print('Context: $context');

      // Send request with timeout
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Handle 401 Unauthorized
      if (response.statusCode == 401) {
        throw const AuthException('Session expired. Please login again.');
      }

      if (response.statusCode == 415) {
        throw const ServerException('Unsupported media type');
      }

      // Handle other errors
      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to generate caption: ${response.body}',
        );
      }

      // Parse response
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final caption = data['caption'] as String?;

      if (caption == null) {
        throw const ServerException('No caption in response');
      }

      return caption;
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      print('=== GENERATE CAPTION ERROR ===');
      print('Error: $e');
      throw ServerException(e.toString());
    }
  }

  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
