import 'package:dartz/dartz.dart';
import 'package:imphenhackaton/core/error/failures.dart';
import 'package:imphenhackaton/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing out.
class SignOut {
  SignOut(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call() {
    return _repository.signOut();
  }
}
