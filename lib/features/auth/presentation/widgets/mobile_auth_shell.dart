import 'package:flutter/material.dart';
import 'package:go_customer/core/layout/acquisition_layout.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/theme/app_colors.dart';
import '../data/login_web_content.dart';
import '../notifiers/login_state.dart';
import 'onboarding_widgets.dart';

/// Hero photo shared with web login and onboarding.
const String kMobileAuthHeroPhoto = 'assets/onboarding_preference.jpg';

String loginPanelKeyForStep(LoginStep step) {
  return switch (step) {
    LoginStep.phone || LoginStep.otp => 'login',
    LoginStep.name => 'name',
    LoginStep.referral => 'referral',
    LoginStep.contactChannels => 'contactChannels',
  };
}

/// Onboarding-style shell for phone and portrait-tablet auth/setup steps.
///
/// Hero imagery on top, elevated form card anchored to the bottom.
class MobileAuthShell extends StatelessWidget {
  const MobileAuthShell({
    super.key,
    required this.panel,
    required this.child,
    this.title,
    this.subtitle,
    this.headerExtra,
    this.setupStepCurrent,
    this.setupStepTotal = 3,
    this.onBack,
    this.showTrustTiles = true,
    this.showEyebrow = true,
  });

  final LoginWebPanel panel;
  final Widget child;

  /// When null, uses [panel.heading].
  final String? title;

  /// When null, uses [panel.subheading].
  final String? subtitle;

  /// Placed between subtitle and trust tiles (e.g. OTP phone line).
  final Widget? headerExtra;

  /// Zero-based setup step index; null hides the progress bar.
  final int? setupStepCurrent;
  final int setupStepTotal;
  final VoidCallback? onBack;
  final bool showTrustTiles;
  final bool showEyebrow;

  @override
  Widget build(BuildContext context) {
    final portraitTablet = AcquisitionLayout.isPortraitTablet(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final screenH = MediaQuery.sizeOf(context).height;
    final heroH = (screenH * 0.38).clamp(240.0, 360.0);
    final frameColor =
        portraitTablet ? AppColors.surface : AppColors.background;

    Widget card = _MobileAuthFormCard(
      floating: portraitTablet,
      bottomInset: bottomInset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onBack != null || setupStepCurrent != null) ...[
            Row(
              children: [
                if (onBack != null)
                  _MobileAuthBackButton(onTap: onBack!)
                else
                  const SizedBox(width: 44),
                if (setupStepCurrent != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MobileAuthProgressBar(
                      current: setupStepCurrent!,
                      total: setupStepTotal,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (showEyebrow && panel.eyebrow.isNotEmpty) ...[
            Text(
              panel.eyebrow,
              style: AppTextStyles.sectionLabel.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            title ?? panel.heading,
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.15,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? panel.subheading,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          if (headerExtra != null) ...[
            const SizedBox(height: 10),
            headerExtra!,
          ],
          if (showTrustTiles && panel.tiles.isNotEmpty) ...[
            const SizedBox(height: 14),
            MobileAuthTrustTiles(tiles: panel.tiles),
          ],
          const SizedBox(height: 18),
          child,
        ],
      ),
    );

    if (portraitTablet) {
      card = Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AcquisitionLayout.phoneColumnMaxWidth,
            ),
            child: card,
          ),
        ),
      );
    }

    return ColoredBox(
      color: frameColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroH,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                const OnboardingAssetImage(
                  imagePath: kMobileAuthHeroPhoto,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  expand: true,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.transparent,
                        frameColor.withValues(alpha: 0.45),
                        frameColor.withValues(alpha: 0.88),
                        frameColor,
                      ],
                      stops: const [0.0, 0.3, 0.58, 0.78, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screenH * 0.74),
              child: card,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileAuthFormCard extends StatelessWidget {
  const _MobileAuthFormCard({
    required this.child,
    required this.bottomInset,
    required this.floating,
  });

  final Widget child;
  final double bottomInset;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: floating
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: floating ? 0.06 : 0.08),
            blurRadius: floating ? 16 : 24,
            offset: Offset(0, floating ? -2 : -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + bottomInset),
        child: child,
      ),
    );
  }
}

class _MobileAuthBackButton extends StatelessWidget {
  const _MobileAuthBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderSolid),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MobileAuthProgressBar extends StatelessWidget {
  const _MobileAuthProgressBar({
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = (current + 1) / total;
    return SizedBox(
      height: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                width: constraints.maxWidth,
                height: 3,
                color: AppColors.borderSolid,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * fraction,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Compact trust/value tiles sourced from [login_web_content.dart].
class MobileAuthTrustTiles extends StatelessWidget {
  const MobileAuthTrustTiles({super.key, required this.tiles});

  final List<LoginWebTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tiles.map((tile) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.borderSolid.withValues(alpha: 0.6),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: tile.iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(tile.icon, size: 16, color: tile.iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tile.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (tile.sublabel != null)
                        Text(
                          tile.sublabel!,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
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
