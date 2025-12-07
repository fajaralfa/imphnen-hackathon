import 'package:dartz/dartz.dart';
import 'package:imphenhackaton/core/error/exceptions.dart';
import 'package:imphenhackaton/core/error/failures.dart';
import 'package:imphenhackaton/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:imphenhackaton/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:imphenhackaton/features/auth/domain/entities/user_entity.dart';
import 'package:imphenhackaton/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      await _localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure([e.message]));
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      await _localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure([e.message]));
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _localDataSource.getCachedUser();
      return Right(user);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return _localDataSource.hasCache();
  }

  @override
  Future<Either<Failure, bool>> isTokenExpired() async {
    // TODO: implement isTokenExpired
    try {
      final isExpired = await _localDataSource.isTokenExpired();
      return Right(isExpired);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }
}
