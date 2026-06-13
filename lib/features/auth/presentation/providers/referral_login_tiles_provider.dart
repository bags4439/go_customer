import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../referral/domain/entities/referral_share_settings.dart';
import '../../../referral/presentation/providers/referral_share_providers.dart';
import '../data/login_web_content.dart';

/// Referral-step trust tiles for login / setup flows.
final referralLoginTrustTilesProvider = Provider<List<LoginWebTile>>((ref) {
  final settings =
      ref.watch(referralShareSettingsProvider).valueOrNull ??
      const ReferralShareSettings();
  return buildReferralTrustTiles(settings);
});
