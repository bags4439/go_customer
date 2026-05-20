import 'package:flutter/material.dart';

import 'home_layout_utils.dart';
import 'home_theme.dart';

class HomeErrorBody extends StatelessWidget {
  const HomeErrorBody({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          32,
          32,
          32,
          32 + homeShellFloatingNavScrollBottomExtra(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: HomeColors.bgSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.wifi_off_outlined,
                size: 32,
                color: HomeColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load orders',
              style: homeTextStyle(size: 16, weight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              style: homeTextStyle(size: 13, color: HomeColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 140,
              height: 44,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: HomeColors.border),
                ),
                child: Text(
                  'Retry',
                  style: homeTextStyle(
                    size: 13,
                    weight: FontWeight.w500,
                    color: HomeColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
