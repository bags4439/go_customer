import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/force_update_requirement.dart';

/// Soft ambient background used on force-update screens.
class ForceUpdateAmbientBackground extends StatelessWidget {
  const ForceUpdateAmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7F6F2),
            AppColors.background,
            AppColors.background,
          ],
          stops: [0, 0.4, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -72,
            right: -48,
            child: _AmbientOrb(
              size: 220,
              color: AppColors.secondary.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            top: 120,
            left: -64,
            child: _AmbientOrb(
              size: 180,
              color: AppColors.selectionTint.withValues(alpha: 0.55),
            ),
          ),
          Positioned(
            bottom: -40,
            right: 24,
            child: _AmbientOrb(
              size: 140,
              color: AppColors.surface.withValues(alpha: 0.9),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

/// Branded app icon with update badge and halo rings.
class ForceUpdateHeroBadge extends StatelessWidget {
  const ForceUpdateHeroBadge({super.key, this.scale = 1});

  final double scale;

  static const double _size = 104;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: _size + 24,
        height: _size + 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: _size + 20,
              height: _size + 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
            ),
            Container(
              width: _size + 8,
              height: _size + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.06),
              ),
            ),
            Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.borderSolid),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 32,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF5FA3E5),
                      AppColors.secondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill primary CTA — matches auth / preferences buttons app-wide.
class ForceUpdatePrimaryButton extends StatelessWidget {
  const ForceUpdatePrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  static const double _height = 52;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: enabled ? AppColors.secondary : AppColors.borderSolid,
          borderRadius: AppTheme.pillBorderRadius(_height),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppTheme.pillBorderRadius(_height),
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: enabled ? Colors.white : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: enabled ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForceUpdateStatusChip extends StatelessWidget {
  const ForceUpdateStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_circle_up_rounded,
            size: 14,
            color: AppColors.infoText,
          ),
          const SizedBox(width: 6),
          Text(
            'New version available',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.infoText,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class ForceUpdateVersionCard extends StatelessWidget {
  const ForceUpdateVersionCard({super.key, required this.requirement});

  final ForceUpdateRequirement requirement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSolid),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _VersionTile(
            icon: Icons.smartphone_rounded,
            label: 'Your version',
            value: requirement.installedVersion ?? '—',
            tone: _VersionTone.neutral,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(child: Divider(color: AppColors.borderSolid)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderSolid),
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.borderSolid)),
              ],
            ),
          ),
          _VersionTile(
            icon: Icons.verified_rounded,
            label: 'Required version',
            value: requirement.minimumVersion ?? '—',
            tone: _VersionTone.required,
          ),
        ],
      ),
    );
  }
}

enum _VersionTone { neutral, required }

class _VersionTile extends StatelessWidget {
  const _VersionTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final _VersionTone tone;

  @override
  Widget build(BuildContext context) {
    final isRequired = tone == _VersionTone.required;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isRequired
                ? AppColors.infoBackground
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isRequired ? AppColors.infoText : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'v$value',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isRequired ? AppColors.infoText : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ForceUpdateUnavailableBanner extends StatelessWidget {
  const ForceUpdateUnavailableBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amberBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amberBackground),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'The store link is temporarily unavailable. Contact support '
              'and we will help you install the latest version.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.amberText,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
