import 'package:flutter/material.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../navigation/profile_id_verification_navigation.dart';
import '../../../auth/domain/entities/app_user.dart';

/// Profile home banner when the user has not added identity document data.
class IdVerificationBanner extends StatelessWidget {
  const IdVerificationBanner({
    super.key,
    required this.pulse,
    required this.user,
  });

  final AnimationController pulse;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final docLabel = user.isGhanaian ? 'Ghana Card' : 'Passport';

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final opacity = (0.85 + 0.15 * (1 - (pulse.value - 0.5).abs() * 2))
            .clamp(0.85, 1.0);
        return Opacity(opacity: opacity, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ProfileIdVerificationNavigation.open(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.amberBackground,
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                left: BorderSide(color: AppColors.warning, width: 3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 20,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add your $docLabel',
                        style: AppTextStyles.cardValue.copyWith(
                          fontSize: 12,
                          color: AppColors.amberText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to upload your card number or photo',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.warning,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
