import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/theme/app_colors.dart';
import '../data/onboarding_slides.dart';

/// Cover viewport height for mobile onboarding heroes.
///
/// [pushFromBottom] reserves the lower screen area for the overlapping sheet;
/// the image is cover-fit inside the remaining upper viewport.
double mobileHeroCoverViewportFraction(double pushFromBottom) {
  return 1.0 - pushFromBottom.clamp(0.0, 0.5);
}

/// Mobile onboarding hero: cover-fit inside a viewport sized from
/// [pushFromBottom] so push and zoom stay coupled.
class OnboardingMobileHeroImage extends StatelessWidget {
  const OnboardingMobileHeroImage({
    super.key,
    required this.imagePath,
    required this.pushFromBottom,
    this.alignment = Alignment.topCenter,
  });

  final String imagePath;
  final double pushFromBottom;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final viewportHeight =
        MediaQuery.sizeOf(context).height *
        mobileHeroCoverViewportFraction(pushFromBottom);

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: viewportHeight,
        width: double.infinity,
        child: OnboardingAssetImage(
          key: ValueKey(imagePath),
          imagePath: imagePath,
          fit: BoxFit.cover,
          alignment: alignment,
          expand: true,
        ),
      ),
    );
  }
}

/// Onboarding hero image with shimmer-style fallback on load failure.
class OnboardingAssetImage extends StatelessWidget {
  const OnboardingAssetImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.borderRadius,
    this.expand = false,
  });

  final String imagePath;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  /// When true, fills all space from the parent (full-bleed heroes).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      imagePath,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: AppColors.surface,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 32,
          color: AppColors.textTertiary.withValues(alpha: 0.6),
        ),
      ),
    );

    final clipped = borderRadius == null
        ? image
        : ClipRRect(borderRadius: borderRadius!, child: image);

    if (expand) {
      return SizedBox.expand(child: clipped);
    }
    return clipped;
  }
}

class OnboardingSlideDots extends StatelessWidget {
  const OnboardingSlideDots({
    super.key,
    required this.currentIndex,
    required this.totalSlides,
    required this.accentColor,
    this.activeWidth = 22,
    this.inactiveWidth = 6,
    this.height = 6,
    this.inactiveColor,
  });

  final int currentIndex;
  final int totalSlides;
  final Color accentColor;
  final double activeWidth;
  final double inactiveWidth;
  final double height;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSlides, (i) {
        final active = currentIndex == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 5),
          height: height,
          width: active ? activeWidth : inactiveWidth,
          decoration: BoxDecoration(
            color: active
                ? accentColor
                : (inactiveColor ?? AppColors.borderSolid),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class OnboardingFeatureTiles extends StatelessWidget {
  const OnboardingFeatureTiles({
    super.key,
    required this.tiles,
    this.compact = false,
    this.onDark = false,
  });

  final List<OnboardingTile> tiles;
  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tiles.map((tile) {
        return Padding(
          padding: EdgeInsets.only(bottom: compact ? 6 : 8),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 10 : 12),
            decoration: BoxDecoration(
              color: onDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(compact ? 10 : 12),
              border: Border.all(
                color: onDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : AppColors.borderSolid.withValues(alpha: 0.6),
                width: 0.5,
              ),
              boxShadow: onDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: compact ? 32 : 36,
                  height: compact ? 32 : 36,
                  decoration: BoxDecoration(
                    color: tile.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    tile.icon,
                    size: compact ? 16 : 18,
                    color: tile.iconColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tile.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: onDark ? Colors.white : AppColors.textPrimary,
                      fontSize: compact ? 12 : 13,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class OnboardingQuoteCard extends StatelessWidget {
  const OnboardingQuoteCard({
    super.key,
    required this.quote,
    this.onDark = false,
    this.compact = false,
  });

  final OnboardingQuote quote;
  final bool onDark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.1)
            : AppColors.infoBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.16)
              : AppColors.secondary.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 32 : 36,
            height: compact ? 32 : 36,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                quote.initials,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 10 : 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote.name,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: onDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quote.text,
                  style: AppTextStyles.caption.copyWith(
                    color: onDark
                        ? Colors.white.withValues(alpha: 0.72)
                        : AppColors.textSecondary,
                    height: 1.45,
                    fontSize: compact ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSlideSemantics extends StatelessWidget {
  const OnboardingSlideSemantics({
    super.key,
    required this.slideIndex,
    required this.totalSlides,
    required this.slide,
    required this.child,
  });

  final int slideIndex;
  final int totalSlides;
  final OnboardingSlide slide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final plainTitle = slide.title.replaceAll('\n', ' ');
    return Semantics(
      container: true,
      label: 'Slide ${slideIndex + 1} of $totalSlides. $plainTitle',
      child: child,
    );
  }
}
