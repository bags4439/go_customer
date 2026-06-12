import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/force_update_providers.dart';
import 'force_update_screen.dart';

/// Blocks outdated iOS/Android builds before routed content is shown.
/// Must be used inside [MaterialApp.builder] so [Scaffold] has [Directionality].
class ForceUpdateGate extends ConsumerWidget {
  const ForceUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      return child;
    }

    final requirementAsync = ref.watch(forceUpdateRequirementProvider);

    return requirementAsync.when(
      loading: () => child,
      error: (_, __) => child,
      data: (requirement) {
        if (!requirement.isRequired) {
          return child;
        }
        return ForceUpdateScreen(requirement: requirement);
      },
    );
  }
}
