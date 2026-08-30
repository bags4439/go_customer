import 'package:dartz/dartz.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/preference_submission.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_firestore_data_source.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesFirestoreDataSource _dataSource;

  const PreferencesRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, String>> createOrderFromPreferences({
    required String buyerId,
    required PreferenceSubmission submission,
    required String idempotencyKey,
    String? assistedCustomerPhone,
  }) async {
    try {
      final id = await _dataSource.createOrderFromPreferences(
        buyerId: buyerId,
        submission: submission,
        idempotencyKey: idempotencyKey,
        assistedCustomerPhone: assistedCustomerPhone,
      );
      return right(id);
    } on FirebaseFunctionsException catch (e) {
      return left(
        FirestoreFailure(
          message: e.message ?? 'Could not create order.',
          cause: e,
        ),
      );
    } catch (e) {
      return left(
        FirestoreFailure(message: 'Could not create order.', cause: e),
      );
    }
  }
}
