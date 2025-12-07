import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:imphenhackaton/core/error/failures.dart';

/// Base class for all use cases in the application.
///
/// [Type] is the return type of the use case.
/// [Params] is the type of parameters the use case accepts.
///
/// Use cases encapsulate a single piece of business logic and
/// represent actions that can be performed in the system.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this class when a use case doesn't require any parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
