import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/referral_share_settings.dart';

abstract class ReferralShareSettingsRepository {
  Future<Either<Failure, ReferralShareSettings>> getShareSettings();
}
