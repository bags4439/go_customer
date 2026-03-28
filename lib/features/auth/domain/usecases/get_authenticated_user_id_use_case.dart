import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class GetAuthenticatedUserIdUseCase {
  final AuthRepository _repository;
  const GetAuthenticatedUserIdUseCase(this._repository);

  Future<Either<Failure, String>> call() =>
      _repository.getAuthenticatedUserId();
}
