/// Base class for all exceptions in the application.
/// Exceptions are thrown when something unexpected happens.
class ServerException implements Exception {
  const ServerException([this.message]);

  final String? message;

  @override
  String toString() => message ?? 'ServerException';
}

/// Exception thrown when there's an issue with local cache/storage.
class CacheException implements Exception {
  const CacheException([this.message]);

  final String? message;

  @override
  String toString() => message ?? 'CacheException';
}
