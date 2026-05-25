import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RepairPulsingDots extends StatefulWidget {
  const RepairPulsingDots({super.key});

  @override
  State<RepairPulsingDots> createState() => _RepairPulsingDotsState();
}

class _RepairPulsingDotsState extends State<RepairPulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = ((_controller.value - delay).clamp(0.0, 1.0) * 2 - 1)
                .abs();
            final opacity = 0.3 + 0.7 * (1 - t);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}
