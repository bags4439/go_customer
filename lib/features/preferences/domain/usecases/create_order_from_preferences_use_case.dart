import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/preference_submission.dart';
import '../repositories/preferences_repository.dart';

class CreateOrderFromPreferencesUseCase {
  final PreferencesRepository _repository;

  const CreateOrderFromPreferencesUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String buyerId,
    required PreferenceSubmission submission,
  }) {
    return _repository.createOrderFromPreferences(
      buyerId: buyerId,
      submission: submission,
    );
  }
}

