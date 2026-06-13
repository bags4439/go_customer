import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../core/constants/profile_constants.dart';
import 'package:go_customer/core/theme/app_colors.dart';

class ProfileAnimatedHeaderCard extends StatelessWidget {
  const ProfileAnimatedHeaderCard({
    super.key,
    required this.controller,
    required this.animation,
    required this.user,
  });

  final AnimationController controller;
  final Animation<double> animation;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              ProfileAvatarCircle(user: user),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.phone,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileAvatarCircle extends StatelessWidget {
  const ProfileAvatarCircle({super.key, required this.user});

  final AppUser user;

  String get _initials {
    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.isNotEmpty
          ? parts.first.substring(0, 1).toUpperCase()
          : '?';
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: AppTextStyles.amountMedium.copyWith(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          if (user.isVerified)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 10, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class ProfileOrderSummaryRow extends StatelessWidget {
  const ProfileOrderSummaryRow({
    super.key,
    required this.animation,
    required this.activeCount,
    required this.completedCount,
    required this.agentFirstName,
  });

  final Animation<double> animation;
  final int activeCount;
  final int completedCount;
  final String agentFirstName;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return Opacity(opacity: t, child: child);
      },
      child: Row(
        children: [
          Expanded(
            child: ProfileSummaryBox(
              value: '$activeCount',
              valueColor: AppColors.brand,
              label: ProfileConstants.activeLabel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ProfileSummaryBox(
              value: '$completedCount',
              valueColor: AppColors.success,
              label: ProfileConstants.completedLabel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ProfileSummaryBox(
              value: agentFirstName,
              valueColor: Colors.black87,
              valueSize: 14,
              label: ProfileConstants.yourAgentLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSummaryBox extends StatelessWidget {
  const ProfileSummaryBox({
    super.key,
    required this.value,
    required this.valueColor,
    required this.label,
    this.valueSize = 18,
  });

  final String value;
  final Color valueColor;
  final String label;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: valueSize,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileOrderSummaryShimmer extends StatelessWidget {
  const ProfileOrderSummaryShimmer({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return Opacity(opacity: t, child: child);
      },
      child: Row(
        children: List.generate(
          3,
          (_) => Expanded(
            child: Container(
              height: 60,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
