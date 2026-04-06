import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/guide_repository.dart';

class ResetGuideUseCase {
  const ResetGuideUseCase(this._repository);
  final GuideRepository _repository;

  Future<Either<Failure, Unit>> call() {
    return _repository.resetAll();
  }
}
