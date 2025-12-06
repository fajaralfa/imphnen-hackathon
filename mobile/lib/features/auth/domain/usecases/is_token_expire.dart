import 'package:dartz/dartz.dart';
import 'package:imphenhackaton/core/core.dart';
import 'package:imphenhackaton/features/auth/domain/repositories/auth_repository.dart';

class CheckTokenValidity extends UseCase<bool, NoParams> {
  CheckTokenValidity(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return _repository.isTokenExpired();
  }
}
