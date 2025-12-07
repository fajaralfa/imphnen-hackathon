import 'package:dartz/dartz.dart';
import 'package:imphenhackaton/core/error/failures.dart';
import 'package:imphenhackaton/features/auth/domain/entities/user_entity.dart';
import 'package:imphenhackaton/features/auth/domain/repositories/auth_repository.dart';

/// Use case for getting the current cached user.
class GetCurrentUser {
  GetCurrentUser(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity?>> call() {
    return _repository.getCurrentUser();
  }
}
