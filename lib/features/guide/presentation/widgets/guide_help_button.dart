import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'guide_faq_sheet.dart';

/// A "?" IconButton for AppBars on screens that
/// have a coach mark. Tapping it:
/// 1. Calls onShowGuide to re-show the coach mark
///    for that specific screen
/// 2. Shows "View FAQ" option via FAQ sheet
///
/// Usage in AppBar:
/// ```dart
/// actions: [
///   GuideHelpButton(
///     onShowGuide: showCoachMarkManually,
///   ),
/// ],
/// ```
class GuideHelpButton extends StatelessWidget {
  const GuideHelpButton({super.key, this.onShowGuide});

  /// Called when the user wants to re-see the
  /// coach mark for this screen.
  /// If null, tapping opens the FAQ directly.
  final VoidCallback? onShowGuide;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSolid, width: 0.5),
        ),
        child: const Icon(
          Icons.question_mark_rounded,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
      onPressed: () => _onTap(context),
      tooltip: 'Help',
      padding: const EdgeInsets.only(right: 8),
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    );
  }

  void _onTap(BuildContext context) {
    if (onShowGuide != null) {
      // Show guide first — FAQ link is inside the
      // coach mark card
      onShowGuide!();
    } else {
      // No guide for this screen — go straight
      // to FAQ
      GuideFaqSheet.show(context);
    }
  }
}
