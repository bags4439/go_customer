import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Verifies OTP and returns Firebase Auth uid (legacy registration flow).
class VerifyPhoneOtpUidUseCase {
  final AuthRepository _repository;
  const VerifyPhoneOtpUidUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String verificationId,
    required String smsCode,
  }) =>
      _repository.verifyOtpAndReturnUid(
        verificationId: verificationId,
        smsCode: smsCode,
      );
}
