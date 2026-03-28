import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/referral_share_settings.dart';
import '../../domain/repositories/referral_share_settings_repository.dart';
import '../datasources/referral_share_settings_firestore_data_source.dart';

class ReferralShareSettingsRepositoryImpl implements ReferralShareSettingsRepository {
  ReferralShareSettingsRepositoryImpl(this._dataSource);

  final ReferralShareSettingsFirestoreDataSource _dataSource;

  @override
  Future<Either<Failure, ReferralShareSettings>> getShareSettings() async {
    try {
      final raw = await _dataSource.fetchRaw();
      return Right(
        ReferralShareSettings(
          referralDiscountGhs: raw['referralDiscountGhs'] as double?,
          appStoreUrl: raw['appStoreUrl'] as String?,
          playstoreUrl: raw['playstoreUrl'] as String?,
          websiteUrl: raw['websiteUrl'] as String?,
        ),
      );
    } catch (e) {
      return Left(FirestoreFailure(message: e.toString()));
    }
  }
}
