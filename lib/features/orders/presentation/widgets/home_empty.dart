part of '../screens/home_screen.dart';

String _timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'GOOD MORNING';
  } else if (hour < 17) {
    return 'GOOD AFTERNOON';
  } else {
    return 'GOOD EVENING';
  }
}

class _EmptyHome extends ConsumerStatefulWidget {
  final String? firstName;

  const _EmptyHome({this.firstName});

  @override
  ConsumerState<_EmptyHome> createState() => _EmptyHomeState();
}

class _EmptyHomeState extends ConsumerState<_EmptyHome>
    with CoachMarkMixin<_EmptyHome> {
  final _importButtonKey = GlobalKey();

  @override
  String get coachMarkKey => GuideKeys.homeEmpty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              20 + _shellFloatingNavScrollBottomExtra(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _timeGreeting(),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _C.textTertiary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.firstName != null
                      ? 'Hi ${widget.firstName}'
                      : 'Welcome',
                  style: GoogleFonts.dmSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ready to buy your first car?',
                  style: GoogleFonts.dmSans(
                    fontSize: 13.5,
                    color: _C.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // CTA card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _C.bgPrimary,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _C.border,
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _CtaIllustration(),
                            const SizedBox(height: 16),

                            Text(
                              'Buy your car from the US, Dubai or China',
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _C.textPrimary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'Tell us what you want — we handle everything '
                              'from auction to your driveway.',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: _C.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 18),

                            SizedBox(
                              key: _importButtonKey,
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => GoRouter.of(context)
                                    .push('/preferences/new'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _C.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Get started',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: _C.bgSecondary,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(17),
                            bottomRight: Radius.circular(17),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: _C.border,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 11,
                              color: _C.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'No payment until your agent sends a request',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: _C.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'HOW IT WORKS',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _C.textTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                  children: [
                    _FeatureItem(
                      iconBg: _C.infoBg,
                      title: 'Dedicated agent',
                      subtitle: 'Matched to you\nwithin minutes',
                      iconWidget: CustomPaint(
                        painter: _AgentIconPainter(),
                      ),
                    ),
                    _FeatureItem(
                      iconBg: _C.successBg,
                      title: 'Every step tracked',
                      subtitle: 'Live updates from\nauction/purchase to delivery',
                      iconWidget: CustomPaint(
                        painter: _TrackingIconPainter(),
                      ),
                    ),
                    _FeatureItem(
                      iconBg: _C.warningBg,
                      title: 'Duty & clearance',
                      subtitle: 'GRA paperwork\nfully managed',
                      iconWidget: CustomPaint(
                        painter: _ClearanceIconPainter(),
                      ),
                    ),
                    _FeatureItem(
                      iconBg: _C.infoBg,
                      title: 'Door delivery',
                      subtitle: 'Straight to your\nhome in Ghana',
                      iconWidget: CustomPaint(
                        painter: _DeliveryIconPainter(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                const ReferralPromoCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        if (showCoachMark)
          CoachMarkOverlay(
            guideKey: GuideKeys.homeEmpty,
            targetKey: _importButtonKey,
            title: 'Import your first car',
            body: 'Tap here to tell us exactly what '
                'car you want. No payment is ever '
                'taken until your agent sends a '
                'payment request.',
            spotlightShape: SpotlightShape.roundedRect,
            cardPosition: CardPosition.above,
            onDismiss: hideCoachMark,
            onFaqTap: () {
              hideCoachMark();
              GuideFaqSheet.show(context);
            },
          ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final Widget iconWidget;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _FeatureItem({
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
        color: _C.bgPrimary,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: _C.border,
          width: 0.5,
        ),
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
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 10.5,
              color: _C.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom illustration for the CTA card showing a car silhouette
/// with origin market labels.
class _CtaIllustration extends StatelessWidget {
  const _CtaIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 96,
      decoration: BoxDecoration(
        color: _C.infoBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: _CtaIllustrationPainter(),
      ),
    );
  }
}

class _CtaIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()
      ..color = _C.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final blueFill = Paint()
      ..color = _C.primary.withValues(alpha: 0.12)
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
        ..color = _C.primary.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    final wheelPaint = Paint()
      ..color = _C.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 16, cy + 9), 5, wheelPaint);
    canvas.drawCircle(Offset(cx + 16, cy + 9), 5, wheelPaint);
    canvas.drawCircle(
      Offset(cx - 16, cy + 9),
      2.5,
      Paint()
        ..color = _C.infoBg
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx + 16, cy + 9),
      2.5,
      Paint()
        ..color = _C.infoBg
        ..style = PaintingStyle.fill,
    );

    final dashPaint = Paint()
      ..color = _C.primary.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final startX = cx + 30.0;
    final endX = size.width * 0.62;
    var x = startX;
    while (x < endX) {
      final next = (x + 4).clamp(x, endX).toDouble();
      canvas.drawLine(
        Offset(x, cy),
        Offset(next, cy),
        dashPaint,
      );
      x += 7;
    }

    canvas.drawCircle(
      Offset(endX, cy),
      6,
      Paint()
        ..color = _C.primary.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(endX, cy),
      6,
      Paint()
        ..color = _C.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final checkPaint = Paint()
      ..color = _C.primary
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
      ('US / Canada', _C.infoText, _C.infoBg),
      ('Dubai', _C.amberText, _C.warningBg),
      ('China', _C.successMutedForeground, _C.successBg),
    ];

    for (var i = 0; i < origins.length; i++) {
      final (label, textCol, bgCol) = origins[i];
      final lx = labelX;
      final ly = cy - labelSpacing + (i * labelSpacing);

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: GoogleFonts.dmSans(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: textCol,
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
  bool shouldRepaint(covariant _CtaIllustrationPainter oldDelegate) => false;
}

class _AgentIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _C.infoText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(
      Offset(cx, cy - 4),
      3.2,
      p,
    );
    final bodyPath = Path()
      ..moveTo(cx - 6, cy + 7)
      ..quadraticBezierTo(
        cx - 6,
        cy + 2,
        cx,
        cy + 1,
      )
      ..quadraticBezierTo(
        cx + 6,
        cy + 2,
        cx + 6,
        cy + 7,
      );
    canvas.drawPath(bodyPath, p);

    final ap = Paint()
      ..color = _C.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(
      Offset(cx + 7, cy - 6),
      Offset(cx + 11, cy - 6),
      ap,
    );
    final arrowPath = Path()
      ..moveTo(cx + 9.5, cy - 7.5)
      ..lineTo(cx + 11, cy - 6)
      ..lineTo(cx + 9.5, cy - 4.5);
    canvas.drawPath(arrowPath, ap);
    canvas.drawCircle(
      Offset(cx + 12.5, cy - 6),
      1.2,
      Paint()
        ..color = _C.primary
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _AgentIconPainter oldDelegate) => false;
}

class _TrackingIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _C.successMutedForeground
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: 14,
        height: 13,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(rrect, p);

    final cp = Paint()
      ..color = _C.success
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
  bool shouldRepaint(covariant _TrackingIconPainter oldDelegate) => false;
}

class _ClearanceIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _C.amberText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + 2),
        width: 13,
        height: 10,
      ),
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
        ..color = _C.warning
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(cx, cy + 3.5),
      Offset(cx, cy + 5.5),
      Paint()
        ..color = _C.warning
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ClearanceIconPainter oldDelegate) => false;
}

class _DeliveryIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _C.infoText
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
        ..color = _C.infoText
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx - 4, cy + 3.5),
      1.8,
      Paint()
        ..color = _C.infoText
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
    canvas.drawLine(
      Offset(cx + 6, cy - 3),
      Offset(cx + 6, cy + 2),
      p,
    );
    final cabPath = Path()
      ..moveTo(cx + 6, cy - 3)
      ..lineTo(cx + 6, cy - 1)
      ..lineTo(cx + 9, cy - 1);
    canvas.drawPath(
      cabPath,
      Paint()
        ..color = _C.infoText.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(cx + 2, cy + 3.5),
      1.8,
      Paint()
        ..color = _C.infoText
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx + 7.5, cy + 3.5),
      1.8,
      Paint()
        ..color = _C.infoText
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _DeliveryIconPainter oldDelegate) => false;
}

class _CompactReferralRow extends StatelessWidget {
  const _CompactReferralRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: _C.bgPrimary,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: _C.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _C.warningBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              size: 18,
              color: _C.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite friends, earn rewards',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Share your referral code',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: _C.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: _C.textTertiary,
          ),
        ],
      ),
    );
  }
}
