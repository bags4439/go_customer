import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class CompleteProfileUseCase {
  final AuthRepository _repository;
  const CompleteProfileUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String uid,
    required String fullName,
    required String country,
  }) {
    return _repository.completeProfile(
      uid: uid,
      fullName: fullName,
      country: country,
    );
  }
}
