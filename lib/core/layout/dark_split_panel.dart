import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A stat item shown at the bottom
/// of the dark panel.
class DarkPanelStat {
  const DarkPanelStat({
    required this.value,
    required this.label,
  });
  final String value;
  final String label;
}

/// A quote/testimonial shown above
/// the stats in the dark panel.
class DarkPanelQuote {
  const DarkPanelQuote({
    required this.initials,
    required this.name,
    required this.text,
  });
  final String initials;
  final String name;
  final String text;
}

/// Accent line item — used for the
/// "Stay in the loop" channel list.
class DarkPanelAccentItem {
  const DarkPanelAccentItem({
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final Color color;
  final String title;
  final String subtitle;
}

/// The dark branded right panel
/// shown alongside auth and
/// onboarding forms on web/tablet.
///
/// Renders a deep blue background
/// with SVG geometric decoration,
/// a heading, subheading, and
/// optional stats, quote, or
/// accent items.
class DarkSplitPanel extends StatelessWidget {
  const DarkSplitPanel({
    super.key,
    required this.heading,
    required this.subheading,
    this.eyebrow,
    this.stats,
    this.quote,
    this.accentItems,
  });

  /// Small all-caps label above
  /// the heading. e.g. "TRUSTED BY
  /// BUYERS ACROSS GHANA"
  final String? eyebrow;

  /// Large heading text.
  final String heading;

  /// Smaller subheading below.
  final String subheading;

  /// Up to 3 stat pills at the
  /// bottom of the panel.
  final List<DarkPanelStat>? stats;

  /// Optional quote/testimonial
  /// shown above stats.
  final DarkPanelQuote? quote;

  /// Optional accent items e.g.
  /// channel list for onboarding.
  final List<DarkPanelAccentItem>? accentItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C447C),
      child: Stack(
        children: [
          // SVG geometric background
          Positioned.fill(
            child: CustomPaint(
              painter: _DarkPanelBackgroundPainter(),
            ),
          ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (eyebrow != null) ...[
                    Text(
                      eyebrow!,
                      style: AppTextStyles.sectionLabel.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    heading,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 22,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subheading,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.6,
                    ),
                  ),
                  if (accentItems != null) ...[
                    const SizedBox(height: 18),
                    ...accentItems!.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 3,
                              height: 36,
                              decoration: BoxDecoration(
                                color: item.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.55,
                                      ),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (quote != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.successMutedBackground,
                            ),
                            child: Center(
                              child: Text(
                                quote!.initials,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quote!.name,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  quote!.text,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (stats != null && stats!.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: stats!
                          .map(
                            (s) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.09),
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.value,
                                      style: AppTextStyles.titleMedium.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      s.label,
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.55,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the geometric background
/// decoration for the dark panel.
/// Uses circles and subtle lines
/// in shades of the brand blue.
class _DarkPanelBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = const Color(0xFF185FA5).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final p2 = Paint()
      ..color = const Color(0xFF042C53).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    final p3 = Paint()
      ..color = const Color(0xFF378ADD).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final lineP = Paint()
      ..color = const Color(0xFF378ADD).withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.18),
      size.width * 0.55,
      p1,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.88),
      size.width * 0.45,
      p2,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.2,
      p3,
    );

    final path = Path()
      ..moveTo(
        size.width * 0.1,
        size.height * 0.28,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.22,
        size.width * 0.9,
        size.height * 0.25,
      );
    canvas.drawPath(path, lineP);
  }

  @override
  bool shouldRepaint(covariant _DarkPanelBackgroundPainter oldDelegate) =>
      false;
}
