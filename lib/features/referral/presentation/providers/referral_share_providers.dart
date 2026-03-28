import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/referral_share_settings_firestore_data_source.dart';
import '../../data/repositories/referral_share_settings_repository_impl.dart';
import '../../domain/entities/referral_share_settings.dart';
import '../../domain/repositories/referral_share_settings_repository.dart';
import '../../domain/usecases/get_referral_share_settings_use_case.dart';

final referralShareSettingsDataSourceProvider =
    Provider<ReferralShareSettingsFirestoreDataSource>((ref) {
  return ReferralShareSettingsFirestoreDataSource(ref.watch(firestoreProvider));
});

final referralShareSettingsRepositoryProvider =
    Provider<ReferralShareSettingsRepository>((ref) {
  return ReferralShareSettingsRepositoryImpl(
    ref.watch(referralShareSettingsDataSourceProvider),
  );
});

final getReferralShareSettingsUseCaseProvider =
    Provider<GetReferralShareSettingsUseCase>((ref) {
  return GetReferralShareSettingsUseCase(
    ref.watch(referralShareSettingsRepositoryProvider),
  );
});

/// Loads public referral/share config from `system_settings`. On failure,
/// yields empty settings so the home promo can still show generic copy.
final referralShareSettingsProvider =
    FutureProvider<ReferralShareSettings>((ref) async {
  final result =
      await ref.watch(getReferralShareSettingsUseCaseProvider).call();
  return result.fold(
    (_) => const ReferralShareSettings(),
    (settings) => settings,
  );
});
