import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:imphenhackaton/core/error/exceptions.dart';
import 'package:imphenhackaton/core/error/failures.dart';
import 'package:imphenhackaton/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:imphenhackaton/features/generate_caption/data/datasources/generate_caption_local_data_source.dart';
import 'package:imphenhackaton/features/generate_caption/data/datasources/generate_caption_remote_data_source.dart';
import 'package:imphenhackaton/features/generate_caption/domain/repositories/generate_caption_repository.dart';

/// Implementation of [GenerateCaptionRepository].
class GenerateCaptionRepositoryImpl implements GenerateCaptionRepository {
  GenerateCaptionRepositoryImpl({
    required GenerateCaptionLocalDataSource localDataSource,
    required GenerateCaptionRemoteDataSource remoteDataSource,
    required AuthLocalDataSource authLocalDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _authLocalDataSource = authLocalDataSource;

  final GenerateCaptionLocalDataSource _localDataSource;
  final GenerateCaptionRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<Either<Failure, List<File>>> pickImagesFromGallery({
    int maxImages = 5,
  }) async {
    try {
      final xFiles = await _localDataSource.pickImagesFromGallery(
        maxImages: maxImages,
      );
      final files = xFiles.map((xFile) => File(xFile.path)).toList();
      return Right(files);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, File>> pickImageFromCamera() async {
    try {
      final xFile = await _localDataSource.pickImageFromCamera();
      if (xFile == null) {
        return const Left(CacheFailure()); // User cancelled
      }
      return Right(File(xFile.path));
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> generateCaption({
    required List<File> images,
    String? description,
  }) async {
    try {
      // Get the JWT token from cached user
      final cachedUser = await _authLocalDataSource.getCachedUser();

      if (cachedUser == null || cachedUser.token == null) {
        return const Left(AuthFailure('Not authenticated. Please login.'));
      }

      final caption = await _remoteDataSource.generateCaption(
        images: images,
        context: description,
        authToken: cachedUser.token!,
      );

      return Right(caption);
    } on AuthException catch (e) {
      // Clear cache on auth failure for auto-logout
      await _authLocalDataSource.clearCache();
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(GeneralFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}
