import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../core/constants/profile_constants.dart';
import 'profile_ui_tokens.dart';

class ProfileBodyShimmer extends StatelessWidget {
  const ProfileBodyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + profileShellFloatingNavExtra(context),
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
