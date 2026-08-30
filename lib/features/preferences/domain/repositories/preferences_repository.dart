import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/preference_submission.dart';

abstract class PreferencesRepository {
  Future<Either<Failure, String>> createOrderFromPreferences({
    required String buyerId,
    required PreferenceSubmission submission,
    required String idempotencyKey,
    String? assistedCustomerPhone,
  });
}
