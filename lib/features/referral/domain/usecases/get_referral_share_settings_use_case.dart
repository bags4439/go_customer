import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/referral_share_settings.dart';
import '../repositories/referral_share_settings_repository.dart';

class GetReferralShareSettingsUseCase {
  GetReferralShareSettingsUseCase(this._repository);

  final ReferralShareSettingsRepository _repository;

  Future<Either<Failure, ReferralShareSettings>> call() =>
      _repository.getShareSettings();
}
