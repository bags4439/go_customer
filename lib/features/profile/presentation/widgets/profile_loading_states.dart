import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/acquisition_layout.dart';
import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/profile_constants.dart';
import 'profile_ui_tokens.dart';

class ProfileBodyShimmer extends StatelessWidget {
  const ProfileBodyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: DashboardLayout.flowScrollPadding(
        context,
        top: 16,
        bottom: 16 + profileShellFloatingNavExtra(context),
      ),
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: ProfileUi.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            3,
            (_) => Expanded(
              child: Container(
                height: 60,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: ProfileUi.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileIncompleteSetupBody extends StatelessWidget {
  const ProfileIncompleteSetupBody({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
        AcquisitionLayout.phoneContentPadding(context).horizontal / 2;

    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          24,
          horizontalPadding,
          24 + profileShellFloatingNavExtra(context),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AcquisitionLayout.phoneColumnMaxWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Finish setting up your account',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Finish account setup to start using AutoImport GH.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProfileUi.primary,
                    shape: AppTheme.buttonPillShape,
                  ),
                  child: Text(
                    'Continue setup',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileBodyError extends StatelessWidget {
  const ProfileBodyError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + profileShellFloatingNavExtra(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfileUi.primary,
              ),
              child: Text(
                ProfileConstants.retry,
                style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
