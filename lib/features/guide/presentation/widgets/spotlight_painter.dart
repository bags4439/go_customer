import 'package:flutter/material.dart';

enum SpotlightShape { circle, roundedRect }

/// Paints a full-screen dark scrim with a
/// transparent spotlight cutout over the target
/// element. The progress parameter (0→1) animates
/// the spotlight opening.
class SpotlightPainter extends CustomPainter {
  const SpotlightPainter({
    required this.targetRect,
    required this.shape,
    required this.progress,
    this.padding = 10.0,
    this.scrubOpacity = 0.65,
  });

  final Rect targetRect;
  final SpotlightShape shape;
  final double progress;
  final double padding;

  /// Opacity of the scrim when fully revealed (0–1).
  final double scrubOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final animatedRect = Rect.lerp(
      Rect.fromCenter(
        center: targetRect.center,
        width: 0,
        height: 0,
      ),
      targetRect.inflate(padding),
      Curves.easeOutCubic.transform(progress),
    )!;

    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = Colors.black.withValues(
          alpha: scrubOpacity * progress,
        ),
    );

    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;

    if (shape == SpotlightShape.circle) {
      canvas.drawCircle(
        animatedRect.center,
        animatedRect.shortestSide / 2,
        clearPaint,
      );
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          animatedRect,
          const Radius.circular(14),
        ),
        clearPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(SpotlightPainter old) {
    return old.targetRect != targetRect ||
        old.progress != progress ||
        old.shape != shape ||
        old.padding != padding ||
        old.scrubOpacity != scrubOpacity;
  }
}
