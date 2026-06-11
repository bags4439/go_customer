import 'package:dartz/dartz.dart';

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
  }) async {
    try {
      final id = await _dataSource.createOrderFromPreferences(
        buyerId: buyerId,
        submission: submission,
      );
      return right(id);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not create order.', cause: e));
    }
  }
}
