import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SyncOneSignalUseCase {
  final AuthRepository _repository;

  const SyncOneSignalUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String userId) {
    return _repository.syncOneSignalIdentity(userId);
  }
}

