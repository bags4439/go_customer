import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';

class ShippingLoadingState extends StatelessWidget {
  const ShippingLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Shimmer.fromColors(
              baseColor: AppColors.surface,
              highlightColor: AppColors.background,
              child: Container(
                height: i == 0 ? 100 : (i == 1 ? 180 : 220),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (i < 2) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
