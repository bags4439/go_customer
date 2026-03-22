import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class StartPhoneVerificationUseCase {
  final AuthRepository _repository;

  const StartPhoneVerificationUseCase(this._repository);

  Future<Either<Failure, PhoneVerificationSession>> call({
    required String phoneNumber,
    int? resendToken,
  }) {
    return _repository.startPhoneVerification(
      phoneNumber: phoneNumber,
      resendToken: resendToken,
    );
  }
}

