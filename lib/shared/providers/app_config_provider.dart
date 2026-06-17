import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import 'system_settings_provider.dart';

/// Branding and support URLs merged from [systemSettingsProvider] + code defaults.
///
/// While settings are loading or on error, returns [AppConfig.defaults] with any
/// keys already present in a partial map.
final appConfigProvider = Provider<AppConfig>((ref) {
  final settingsAsync = ref.watch(systemSettingsProvider);
  final map = settingsAsync.valueOrNull ?? const <String, dynamic>{};
  return resolveAppConfig(map);
});
