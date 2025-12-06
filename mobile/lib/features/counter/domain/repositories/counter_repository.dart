import 'package:dartz/dartz.dart';
import 'package:imphenhackaton/core/error/failures.dart';
import 'package:imphenhackaton/features/counter/domain/entities/counter_entity.dart';

/// Abstract repository interface for Counter operations.
///
/// This is part of the domain layer and defines the contract
/// that any data layer implementation must fulfill.
/// The actual implementation lives in the data layer.
abstract class CounterRepository {
  /// Gets the current counter value.
  Future<Either<Failure, CounterEntity>> getCounter();

  /// Increments the counter and returns the new value.
  Future<Either<Failure, CounterEntity>> incrementCounter();

  /// Decrements the counter and returns the new value.
  Future<Either<Failure, CounterEntity>> decrementCounter();
}
