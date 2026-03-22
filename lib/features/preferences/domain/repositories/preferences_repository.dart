import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/preference_submission.dart';

abstract class PreferencesRepository {
  Future<Either<Failure, String>> createOrderFromPreferences({
    required String buyerId,
    required PreferenceSubmission submission,
  });

  Future<Either<Failure, Map<String, dynamic>?>> getCarPreferences(String orderId);

  Future<Either<Failure, Unit>> updateCarPreferencesAndNotify({
    required String orderId,
    required String preferenceId,
    required Map<String, dynamic> newValues,
    required Map<String, dynamic> originalValues,
    required String editedByUserId,
  });
}

