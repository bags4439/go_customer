import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/preference_submission.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_firestore_data_source.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesFirestoreDataSource _dataSource;
  final FirebaseFunctions _functions;

  const PreferencesRepositoryImpl(this._dataSource, this._functions);

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

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getCarPreferences(
      String orderId) async {
    try {
      final data = await _dataSource.getCarPreferences(orderId);
      return right(data);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not load preferences.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCarPreferencesAndNotify({
    required String orderId,
    required String preferenceId,
    required Map<String, dynamic> newValues,
    required Map<String, dynamic> originalValues,
    required String editedByUserId,
  }) async {
    try {
      final updateMap = <String, dynamic>{
        'make': newValues['make'],
        'model': newValues['model'],
        'yearMin': newValues['yearMin'],
        'yearMax': newValues['yearMax'],
        'isSingleYear': newValues['isSingleYear'],
        'condition': newValues['condition'],
        'conditionLabel': newValues['conditionLabel'],
        'maxMileage': newValues['maxMileage'],
        'repairOptedIn': newValues['repairOptedIn'],
      };
      await _dataSource.updateCarPreferences(preferenceId, updateMap);
      await _dataSource.createPreferenceEditHistory(
        orderId: orderId,
        editedByUserId: editedByUserId,
        editedByRole: 'buyer',
        previousValuesJson: originalValues,
        newValuesJson: newValues,
      );
      await _functions
          .httpsCallable('notifyAgentPreferencesEdited')
          .call({'orderId': orderId});
      return right(unit);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not save.', cause: e));
    }
  }
}

