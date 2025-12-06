import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Failures are used to represent expected errors that can be handled gracefully.
abstract class Failure extends Equatable {
  const Failure([this.properties = const <dynamic>[]]);

  final List<dynamic> properties;

  @override
  List<Object?> get props => properties;
}

/// Represents a failure that occurs on the server side.
class ServerFailure extends Failure {
  const ServerFailure([super.properties]);
}

/// Represents a failure that occurs with local caching/storage.
class CacheFailure extends Failure {
  const CacheFailure([super.properties]);
}

/// Represents a general failure with a custom message.
class GeneralFailure extends Failure {
  const GeneralFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Represents an authentication failure (e.g., 401 Unauthorized).
/// Used to trigger auto-logout when token is invalid/expired.
class AuthFailure extends Failure {
  const AuthFailure([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}
