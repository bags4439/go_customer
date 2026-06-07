import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/package_info_provider.dart';
import '../../../../shared/providers/system_settings_provider.dart';
import '../../data/force_update_config_resolver.dart';
import '../../domain/entities/force_update_requirement.dart';
import '../../domain/usecases/check_force_update_required_use_case.dart';
import '../../domain/usecases/compare_semantic_versions_use_case.dart';

final _checkForceUpdateRequiredUseCaseProvider =
    Provider<CheckForceUpdateRequiredUseCase>(
  (ref) => CheckForceUpdateRequiredUseCase(
    CompareSemanticVersionsUseCase(),
  ),
);

const _configResolver = ForceUpdateConfigResolver();

/// Evaluates whether the current native build must be updated before app use.
/// Fails open on web, unsupported platforms, and load errors.
final forceUpdateRequirementProvider =
    FutureProvider<ForceUpdateRequirement>((ref) async {
  if (kIsWeb) {
    return ForceUpdateRequirement.notRequired();
  }

  final platform = defaultTargetPlatform;
  if (!_configResolver.isSupportedNativePlatform(platform)) {
    return ForceUpdateRequirement.notRequired();
  }

  try {
    final packageInfo = await ref.watch(packageInfoProvider.future);
    final settings = await ref.watch(systemSettingsProvider.future);
    final minimumVersion =
        _configResolver.minimumVersionForPlatform(settings, platform);

    final isRequired = ref
        .read(_checkForceUpdateRequiredUseCaseProvider)
        .call(
          installedVersion: packageInfo.version,
          minimumVersion: minimumVersion,
        );

    if (!isRequired) {
      return ForceUpdateRequirement.notRequired();
    }

    return ForceUpdateRequirement.required(
      installedVersion: packageInfo.version,
      minimumVersion: minimumVersion!.trim(),
      storeUrl: _configResolver.storeUrlForPlatform(settings, platform),
      storeLabel: _configResolver.storeLabelForPlatform(platform),
      isIos: platform == TargetPlatform.iOS,
    );
  } catch (_) {
    return ForceUpdateRequirement.notRequired();
  }
});
