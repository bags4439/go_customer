import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository _repository;

  const RegisterUserUseCase(this._repository);

  Future<Either<Failure, Unit>> call(RegisterUserParams params) {
    return _repository.createUserProfile(params);
  }
}

