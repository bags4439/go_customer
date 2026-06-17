import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import 'package_info_provider.dart';

/// Display label for profile and settings, e.g. "Whiplyn v1.0.0".
/// Sourced from [packageInfoProvider] so it always matches force-update gating.
final appVersionLabelProvider = Provider<String>((ref) {
  final packageInfoAsync = ref.watch(packageInfoProvider);

  return packageInfoAsync.when(
    data: (info) => '${AppConstants.appName} v${info.version}',
    loading: () => AppConstants.appName,
    error: (_, __) => AppConstants.appName,
  );
});
