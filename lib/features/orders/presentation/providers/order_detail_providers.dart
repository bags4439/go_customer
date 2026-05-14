import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Web-only: holds the stageKey of the timeline step currently open in the
/// right panel. Null = default (agent card).
final webSelectedStepProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);
