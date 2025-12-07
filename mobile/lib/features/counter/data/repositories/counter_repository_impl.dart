import 'package:dartz/dartz.dart';
import 'package:imphenhackaton/core/error/exceptions.dart';
import 'package:imphenhackaton/core/error/failures.dart';
import 'package:imphenhackaton/features/counter/data/datasources/counter_local_data_source.dart';
import 'package:imphenhackaton/features/counter/domain/entities/counter_entity.dart';
import 'package:imphenhackaton/features/counter/domain/repositories/counter_repository.dart';

/// Implementation of [CounterRepository] from the domain layer.
///
/// This class orchestrates data operations between data sources.
/// It handles error conversion from exceptions to failures,
/// making the domain layer independent of data layer errors.
class CounterRepositoryImpl implements CounterRepository {
  CounterRepositoryImpl({required this.localDataSource});

  final CounterLocalDataSource localDataSource;

  @override
  Future<Either<Failure, CounterEntity>> getCounter() async {
    try {
      final counter = await localDataSource.getCounter();
      return Right(counter.toEntity());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CounterEntity>> incrementCounter() async {
    try {
      final counter = await localDataSource.incrementCounter();
      return Right(counter.toEntity());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CounterEntity>> decrementCounter() async {
    try {
      final counter = await localDataSource.decrementCounter();
      return Right(counter.toEntity());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}
