import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  const VerifyOtpUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String verificationId,
    required String smsCode,
  }) {
    return _repository.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}

