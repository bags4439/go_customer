import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/system_settings_provider.dart';
import 'session_config.dart';

final sessionConfigProvider = Provider<SessionConfig>((ref) {
  final settings = ref.watch(systemSettingsProvider).valueOrNull ??
      const <String, dynamic>{};
  return resolveSessionConfig(settings);
});
