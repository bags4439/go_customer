import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Visual treatment for the in-app wordmark + icon.
enum AppLogoStyle {
  /// App icon + dark wordmark (auth, home app bar).
  standard,

  /// App icon + white wordmark on brand backgrounds (launch splash).
  onBrand,

  /// Smaller wordmark for compact headers.
  compact,
}

/// Shared Whiplyn logo — [AppBrandingDefaults.launcherIconAsset] + wordmark.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.fontSize,
    this.style = AppLogoStyle.standard,
  });

  final double? fontSize;
  final AppLogoStyle style;

  double get _fontSize => fontSize ?? switch (style) {
        AppLogoStyle.compact => 17,
        AppLogoStyle.onBrand => 28,
        AppLogoStyle.standard => 26,
      };

  double get _iconSize => _fontSize * 1.4;

  @override
  Widget build(BuildContext context) {
    final onBrand = style == AppLogoStyle.onBrand;
    final textColor = onBrand ? Colors.white : AppColors.textPrimary;
    final textStyle = onBrand
        ? GoogleFonts.dmSans(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.1,
          )
        : AppTextStyles.titleLarge.copyWith(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.1,
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _AppLogoMark(
          size: _iconSize,
          borderRadius: _fontSize * 0.3,
          elevated: onBrand,
        ),
        const SizedBox(width: 10),
        Text(AppBrandingDefaults.displayName, style: textStyle),
      ],
    );
  }
}

class _AppLogoMark extends StatelessWidget {
  const _AppLogoMark({
    required this.size,
    required this.borderRadius,
    required this.elevated,
  });

  final double size;
  final double borderRadius;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final mark = ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        AppBrandingDefaults.launcherIconAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => ColoredBox(
          color: AppColors.brand,
          child: Icon(
            Icons.directions_car_filled,
            color: Colors.white,
            size: size * 0.6,
          ),
        ),
      ),
    );

    if (!elevated) return mark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: mark,
    );
  }
}
