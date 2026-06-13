import 'package:flutter/material.dart';

import 'home_empty_illustrations.dart';
import 'package:go_customer/core/theme/app_colors.dart';

/// Responsive "How it works" feature grid using [Wrap] so tile height
/// follows content instead of a fixed [GridView] aspect ratio.
class HomeEmptyHowItWorksGrid extends StatelessWidget {
  const HomeEmptyHowItWorksGrid({super.key});

  static const double _spacing = 8;
  static const double _minTileWidth = 148;

  static final List<_HowItWorksFeatureData> _features = [
    _HowItWorksFeatureData(
      iconBg: AppColors.infoBackground,
      title: 'Dedicated agent',
      subtitle: 'Matched to you\nwithin minutes',
      painter: HomeEmptyAgentIconPainter(),
    ),
    _HowItWorksFeatureData(
      iconBg: AppColors.successMutedBackground,
      title: 'Every step tracked',
      subtitle: 'Live updates from\nauction/purchase to delivery',
      painter: HomeEmptyTrackingIconPainter(),
    ),
    _HowItWorksFeatureData(
      iconBg: AppColors.amberBackground,
      title: 'Duty & clearance',
      subtitle: 'GRA paperwork\nfully managed',
      painter: HomeEmptyClearanceIconPainter(),
    ),
    _HowItWorksFeatureData(
      iconBg: AppColors.infoBackground,
      title: 'Door delivery',
      subtitle: 'Straight to your\nhome in Ghana',
      painter: HomeEmptyDeliveryIconPainter(),
    ),
  ];

  /// Picks the most columns that still respect [_minTileWidth].
  static int columnCountForWidth(double width) {
    for (var columns = 4; columns >= 1; columns--) {
      final minRequired = _minTileWidth * columns + _spacing * (columns - 1);
      if (width >= minRequired) return columns;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (!maxWidth.isFinite || maxWidth <= 0) {
          return const SizedBox.shrink();
        }

        final columns = columnCountForWidth(maxWidth);
        final tileWidth = (maxWidth - _spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final feature in _features)
              SizedBox(
                width: tileWidth,
                child: HomeEmptyFeatureItem(
                  iconBg: feature.iconBg,
                  title: feature.title,
                  subtitle: feature.subtitle,
                  iconWidget: CustomPaint(painter: feature.painter),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HowItWorksFeatureData {
  const _HowItWorksFeatureData({
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.painter,
  });

  final Color iconBg;
  final String title;
  final String subtitle;
  final CustomPainter painter;
}
