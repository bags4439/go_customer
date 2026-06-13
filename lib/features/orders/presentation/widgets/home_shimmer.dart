import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/layout/dashboard_layout.dart';
import 'home_layout_utils.dart';
import 'package:go_customer/core/theme/app_colors.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: Colors.white,
      child: Padding(
        padding: DashboardLayout.flowScrollPadding(
          context,
          top: 16,
          bottom: homeShellFloatingNavScrollBottomExtra(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeShimmerBox(width: 180, height: 24, radius: 6),
            const SizedBox(height: 8),
            const HomeShimmerBox(width: 240, height: 14, radius: 4),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: HomeShimmerBox(height: 60, radius: 10)),
                const SizedBox(width: 8),
                const Expanded(child: HomeShimmerBox(height: 60, radius: 10)),
                const SizedBox(width: 8),
                const Expanded(child: HomeShimmerBox(height: 60, radius: 10)),
              ],
            ),
            const SizedBox(height: 20),
            const HomeShimmerBox(width: 80, height: 12, radius: 4),
            const SizedBox(height: 10),
            for (var i = 0; i < 3; i++) ...[
              const HomeShimmerBox(height: 96, radius: 12),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeShimmerBox extends StatelessWidget {
  const HomeShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
