import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import '../value_objects/phone_number.dart';

class RequestOtpUseCase {
  final AuthRepository _repository;
  const RequestOtpUseCase(this._repository);

  Future<Either<Failure, String>> call(
    PhoneNumber phoneNumber,
  ) =>
      _repository.requestOtp(phoneNumber.value);
}
