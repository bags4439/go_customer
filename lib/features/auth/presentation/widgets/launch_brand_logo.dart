import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Logo for the brand-colour launch screen (native splash handoff).
class LaunchBrandLogo extends StatelessWidget {
  const LaunchBrandLogo({super.key, this.fontSize = 28});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: fontSize * 1.4,
          height: fontSize * 1.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(fontSize * 0.3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_car_filled,
            color: AppColors.secondary,
            size: fontSize * 0.85,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'AutoImport',
          style: GoogleFonts.dmSans(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        Text(
          ' GH',
          style: GoogleFonts.dmSans(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.92),
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
