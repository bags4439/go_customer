import 'package:flutter/material.dart';

import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import 'guide_faq_sheet.dart';

/// Opens the common-questions sheet from an app bar.
class GuideHelpButton extends StatelessWidget {
  const GuideHelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    final useMobileShell = AppBreakpoints.useMobileShell(context);
    final chipColor =
        useMobileShell ? AppColors.background : AppColors.surface;

    return IconButton(
      icon: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: chipColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSolid, width: 0.5),
          boxShadow: useMobileShell
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: const Icon(
          Icons.question_mark_rounded,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
      onPressed: () => GuideFaqSheet.show(context),
      tooltip: 'Common questions',
      padding: const EdgeInsets.only(right: 8),
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    );
  }
}
