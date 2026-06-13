import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import 'package:go_customer/core/theme/app_colors.dart';

class HomeEmptyFeatureItem extends StatelessWidget {
  final Widget iconWidget;
  final Color iconBg;
  final String title;
  final String subtitle;

  const HomeEmptyFeatureItem({
    super.key,
    required this.iconWidget,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: iconWidget,
          ),
          const SizedBox(height: 9),
          Text(title, style: AppTextStyles.cardValue),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(fontSize: 10.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// Custom illustration for the CTA card showing a car silhouette
/// with origin market labels.
class HomeEmptyCtaIllustration extends StatelessWidget {
  const HomeEmptyCtaIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(painter: HomeEmptyCtaIllustrationPainter()),
    );
  }
}

class HomeEmptyCtaIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()
      ..color = AppColors.brand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final blueFill = Paint()
      ..color = AppColors.brand.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final cx = size.width * 0.26;
    final cy = size.height * 0.55;

    final bodyPath = Path()
      ..moveTo(cx - 26, cy + 8)
      ..lineTo(cx - 20, cy - 6)
      ..lineTo(cx - 8, cy - 14)
      ..lineTo(cx + 8, cy - 14)
      ..lineTo(cx + 20, cy - 6)
      ..lineTo(cx + 26, cy - 6)
      ..lineTo(cx + 26, cy + 8)
      ..close();
    canvas.drawPath(bodyPath, blueFill);
    canvas.drawPath(bodyPath, bluePaint);

    final windPath = Path()
      ..moveTo(cx - 6, cy - 13)
      ..lineTo(cx - 12, cy - 6)
      ..lineTo(cx + 12, cy - 6)
      ..lineTo(cx + 4, cy - 13)
      ..close();
    canvas.drawPath(
      windPath,
      Paint()
        ..color = AppColors.brand.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    final wheelPaint = Paint()
      ..color = AppColors.brand
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 16, cy + 9), 5, wheelPaint);
    canvas.drawCircle(Offset(cx + 16, cy + 9), 5, wheelPaint);
    canvas.drawCircle(
      Offset(cx - 16, cy + 9),
      2.5,
      Paint()
        ..color = AppColors.infoBackground
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx + 16, cy + 9),
      2.5,
      Paint()
        ..color = AppColors.infoBackground
        ..style = PaintingStyle.fill,
    );

    final dashPaint = Paint()
      ..color = AppColors.brand.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final startX = cx + 30.0;
    final endX = size.width * 0.62;
    var x = startX;
    while (x < endX) {
      final next = (x + 4).clamp(x, endX).toDouble();
      canvas.drawLine(Offset(x, cy), Offset(next, cy), dashPaint);
      x += 7;
    }

    canvas.drawCircle(
      Offset(endX, cy),
      6,
      Paint()
        ..color = AppColors.brand.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(endX, cy),
      6,
      Paint()
        ..color = AppColors.brand
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final checkPaint = Paint()
      ..color = AppColors.brand
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final checkPath = Path()
      ..moveTo(endX - 3.5, cy)
      ..lineTo(endX - 1, cy + 2.5)
      ..lineTo(endX + 3.5, cy - 3);
    canvas.drawPath(checkPath, checkPaint);

    final labelX = endX + 14;
    final labelSpacing = size.height * 0.22;
    final origins = <(String, Color, Color)>[
      ('US / Canada', AppColors.accent, AppColors.infoBackground),
      ('Dubai', AppColors.amberText, AppColors.amberBackground),
      ('China', AppColors.successMutedForeground, AppColors.successMutedBackground),
    ];

    for (var i = 0; i < origins.length; i++) {
      final (label, textCol, bgCol) = origins[i];
      final lx = labelX;
      final ly = cy - labelSpacing + (i * labelSpacing);

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: AppTextStyles.badgeText.copyWith(
            fontWeight: FontWeight.w600,
            color: textCol,
            letterSpacing: 0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          lx - 4,
          ly - tp.height / 2 - 3,
          tp.width + 8,
          tp.height + 6,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        bgRect,
        Paint()
          ..color = bgCol
          ..style = PaintingStyle.fill,
      );

      tp.paint(canvas, Offset(lx, ly - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant HomeEmptyCtaIllustrationPainter oldDelegate) =>
      false;
}

class HomeEmptyAgentIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(Offset(cx, cy - 4), 3.2, p);
    final bodyPath = Path()
      ..moveTo(cx - 6, cy + 7)
      ..quadraticBezierTo(cx - 6, cy + 2, cx, cy + 1)
      ..quadraticBezierTo(cx + 6, cy + 2, cx + 6, cy + 7);
    canvas.drawPath(bodyPath, p);

    final ap = Paint()
      ..color = AppColors.brand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(Offset(cx + 7, cy - 6), Offset(cx + 11, cy - 6), ap);
    final arrowPath = Path()
      ..moveTo(cx + 9.5, cy - 7.5)
      ..lineTo(cx + 11, cy - 6)
      ..lineTo(cx + 9.5, cy - 4.5);
    canvas.drawPath(arrowPath, ap);
    canvas.drawCircle(
      Offset(cx + 12.5, cy - 6),
      1.2,
      Paint()
        ..color = AppColors.brand
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant HomeEmptyAgentIconPainter oldDelegate) => false;
}

class HomeEmptyTrackingIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.successMutedForeground
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 14, height: 13),
      const Radius.circular(2),
    );
    canvas.drawRRect(rrect, p);

    final cp = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final checkPath = Path()
      ..moveTo(cx - 4, cy)
      ..lineTo(cx - 1.5, cy + 2.5)
      ..lineTo(cx + 4, cy - 3);
    canvas.drawPath(checkPath, cp);
  }

  @override
  bool shouldRepaint(covariant HomeEmptyTrackingIconPainter oldDelegate) =>
      false;
}

class HomeEmptyClearanceIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.amberText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 2), width: 13, height: 10),
      const Radius.circular(2),
    );
    canvas.drawRRect(bodyRect, p);

    final shacklePath = Path()
      ..moveTo(cx - 3.5, cy - 3)
      ..lineTo(cx - 3.5, cy - 5.5)
      ..arcToPoint(
        Offset(cx + 3.5, cy - 5.5),
        radius: const Radius.circular(3.5),
      )
      ..lineTo(cx + 3.5, cy - 3);
    canvas.drawPath(shacklePath, p);

    canvas.drawCircle(
      Offset(cx, cy + 2),
      1.8,
      Paint()
        ..color = AppColors.warning
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(cx, cy + 3.5),
      Offset(cx, cy + 5.5),
      Paint()
        ..color = AppColors.warning
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant HomeEmptyClearanceIconPainter oldDelegate) =>
      false;
}

class HomeEmptyDeliveryIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final carPath = Path()
      ..moveTo(cx - 14, cy + 2)
      ..lineTo(cx - 11, cy - 3)
      ..lineTo(cx - 4, cy - 3)
      ..lineTo(cx - 1, cy + 2)
      ..close();
    canvas.drawPath(carPath, p);
    canvas.drawCircle(
      Offset(cx - 11, cy + 3.5),
      1.8,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx - 4, cy + 3.5),
      1.8,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.fill,
    );

    final truckPath = Path()
      ..moveTo(cx - 1, cy - 3)
      ..lineTo(cx - 1, cy + 2)
      ..lineTo(cx + 9, cy + 2)
      ..lineTo(cx + 9, cy - 1)
      ..lineTo(cx + 6, cy - 3)
      ..close();
    canvas.drawPath(truckPath, p);
    canvas.drawLine(Offset(cx + 6, cy - 3), Offset(cx + 6, cy + 2), p);
    final cabPath = Path()
      ..moveTo(cx + 6, cy - 3)
      ..lineTo(cx + 6, cy - 1)
      ..lineTo(cx + 9, cy - 1);
    canvas.drawPath(
      cabPath,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(cx + 2, cy + 3.5),
      1.8,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx + 7.5, cy + 3.5),
      1.8,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant HomeEmptyDeliveryIconPainter oldDelegate) =>
      false;
}
