import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/domain/entities/app_user.dart';

/// Extra bottom padding when home scroll content sits above the mobile floating nav.
double homeShellFloatingNavScrollBottomExtra(BuildContext context) {
  if (!ResponsiveLayout.isMobile(context)) return 0;
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  return bottomInset + 64 + 24;
}

String homeTimeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'GOOD MORNING';
  if (hour < 17) return 'GOOD AFTERNOON';
  return 'GOOD EVENING';
}

String? homeFirstNameFromUser(AsyncValue<AppUser?> userAsync) {
  final user = userAsync.valueOrNull;
  if (user == null || user.fullName.trim().isEmpty) return null;
  final parts = user.fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .toList();
  if (parts.isEmpty) return null;
  return parts.first;
}
