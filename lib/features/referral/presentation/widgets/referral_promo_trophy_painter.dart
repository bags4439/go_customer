import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Faint trophy watermark on the right (reference card style).
class ReferralPromoTrophyPainter extends CustomPainter {
  ReferralPromoTrophyPainter({this.opacity = 0.2});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = Colors.white.withValues(alpha: opacity);
    final cx = w * 0.76;
    final cy = h * 0.5;

    canvas.save();
    canvas.translate(cx, cy);

    final scale = (w * 0.34).clamp(0.85, 1.15);
    canvas.scale(scale);

    // Cup
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, -38, 60, 50),
        const Radius.circular(16),
      ),
      fill,
    );

    // Handles
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      const Rect.fromLTWH(-44, -14, 18, 28),
      0.85 * math.pi,
      0.65 * math.pi,
      false,
      stroke,
    );
    canvas.drawArc(
      const Rect.fromLTWH(26, -14, 18, 28),
      0.5 * math.pi,
      0.65 * math.pi,
      false,
      stroke,
    );

    // Stem
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, 12, 10, 16),
        const Radius.circular(2),
      ),
      fill,
    );
    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-24, 26, 48, 12),
        const Radius.circular(4),
      ),
      fill,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ReferralPromoTrophyPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
