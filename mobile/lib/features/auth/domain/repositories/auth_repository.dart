import 'package:dartz/dartz.dart';
import 'package:imphenhackaton/core/error/failures.dart';
import 'package:imphenhackaton/features/auth/domain/entities/user_entity.dart';

/// Repository interface for authentication feature.
abstract class AuthRepository {
  /// Sign in with Google.
  /// Returns [UserEntity] with token on success.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign out the current user.
  /// Clears local cache and Google session.
  Future<Either<Failure, void>> signOut();

  /// Get the currently cached user.
  /// Returns null if no user is cached.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Check if user is logged in (has cached token).
  Future<bool> isLoggedIn();

  Future<Either<Failure, bool>> isTokenExpired();
}
