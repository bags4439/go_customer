import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/system_settings_provider.dart';
import '../../data/datasources/referral_share_settings_firestore_data_source.dart';
import '../../data/repositories/referral_share_settings_repository_impl.dart';
import '../../domain/entities/referral_share_settings.dart';
import '../../domain/usecases/get_referral_share_settings_use_case.dart';

/// Loads public referral/share config from `system_settings`. On failure,
/// yields empty settings so the home promo can still show generic copy.
final referralShareSettingsProvider = FutureProvider<ReferralShareSettings>((
  ref,
) async {
  final settingsMap = await ref.watch(systemSettingsProvider.future);

  final dataSource = ReferralShareSettingsFirestoreDataSource();
  final repo = ReferralShareSettingsRepositoryImpl(dataSource, settingsMap);

  final result = await GetReferralShareSettingsUseCase(repo).call();
  return result.fold(
    (_) => const ReferralShareSettings(),
    (settings) => settings,
  );
});
