import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Stage-based percent loader — matches the web HTML splash aesthetic.
class LaunchPercentProgress extends StatelessWidget {
  const LaunchPercentProgress({
    super.key,
    required this.percent,
    this.maxWidth = 240,
  });

  final int percent;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0, 100);
    final fillWidth = maxWidth * clamped / 100;

    return Semantics(
      label: 'Loading $clamped percent',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                width: maxWidth,
                height: 4,
                child: ColoredBox(
                  color: AppColors.brand.withValues(alpha: 0.15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      width: fillWidth,
                      height: 4,
                      color: AppColors.brand,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$clamped%',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
