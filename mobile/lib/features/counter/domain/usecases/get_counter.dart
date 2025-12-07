import 'package:dartz/dartz.dart';
import 'package:imphenhackaton/core/error/failures.dart';
import 'package:imphenhackaton/core/usecases/usecase.dart';
import 'package:imphenhackaton/features/counter/domain/entities/counter_entity.dart';
import 'package:imphenhackaton/features/counter/domain/repositories/counter_repository.dart';

/// Use case to get the current counter value.
///
/// Use cases represent a single action or business rule in the application.
/// They depend on repository interfaces (not implementations) following
/// the Dependency Inversion Principle.
class GetCounter implements UseCase<CounterEntity, NoParams> {
  GetCounter(this.repository);

  final CounterRepository repository;

  @override
  Future<Either<Failure, CounterEntity>> call(NoParams params) async {
    return repository.getCounter();
  }
}
