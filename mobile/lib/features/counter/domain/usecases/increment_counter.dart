import 'package:dartz/dartz.dart';
import 'package:imphenhackaton/core/error/failures.dart';
import 'package:imphenhackaton/core/usecases/usecase.dart';
import 'package:imphenhackaton/features/counter/domain/entities/counter_entity.dart';
import 'package:imphenhackaton/features/counter/domain/repositories/counter_repository.dart';

/// Use case to increment the counter.
///
/// This encapsulates the business logic for incrementing the counter,
/// delegating the actual operation to the repository.
class IncrementCounter implements UseCase<CounterEntity, NoParams> {
  IncrementCounter(this.repository);

  final CounterRepository repository;

  @override
  Future<Either<Failure, CounterEntity>> call(NoParams params) async {
    return repository.incrementCounter();
  }
}
