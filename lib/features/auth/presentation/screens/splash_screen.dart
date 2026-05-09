import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/layout/auth_split_layout.dart';
import '../../../../core/layout/dark_split_panel.dart';
import '../widgets/auth_visual_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _shimmerController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _entranceController.forward();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.goNamed(RouteConstants.onboarding);
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = _SplashFormContent(
      logoOpacity: _logoOpacity,
      logoScale: _logoScale,
      taglineOpacity: _taglineOpacity,
      shimmerController: _shimmerController,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppBreakpoints.isMobile(context)
          ? form
          : AppBreakpoints.isWeb(context)
              ? AuthSplitLayout(
                  form: form,
                  panel: const DarkSplitPanel(
                    heading:
                        'Your car, sourced globally.\nDelivered to your door.',
                    subheading:
                        'From US auctions to Dubai dealers — your dedicated '
                        'agent manages everything end to end.',
                  ),
                )
              : _SplashTabletContent(
                  logoOpacity: _logoOpacity,
                  logoScale: _logoScale,
                  taglineOpacity: _taglineOpacity,
                  shimmerController: _shimmerController,
                ),
    );
  }
}

class _SplashFormContent extends StatelessWidget {
  const _SplashFormContent({
    required this.logoOpacity,
    required this.logoScale,
    required this.taglineOpacity,
    required this.shimmerController,
  });

  final Animation<double> logoOpacity;
  final Animation<double> logoScale;
  final Animation<double> taglineOpacity;
  final AnimationController shimmerController;

  static const Color _textSecondary = Color(0xFF666666);
  static const Color _dotColor = Color(0xFFE0DFD8);
  static const Color _shimmerPrimary = Color(0xFF378ADD);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _DotGridPainter(
              color: _dotColor.withValues(alpha: 0.5),
              spacing: 24,
              dotRadius: 1.5,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: logoOpacity,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: logoOpacity,
                    child: ScaleTransition(
                      scale: logoScale,
                      child: child,
                    ),
                  );
                },
                child: const AuthAppLogo(fontSize: 28),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: taglineOpacity,
                child: Text(
                  'Import your dream car from anywhere in the world.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 48 + bottomInset,
          child: Center(
            child: AnimatedBuilder(
              animation: shimmerController,
              builder: (context, child) {
                final t = shimmerController.value;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: SizedBox(
                    width: 48,
                    height: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + 2 * t, 0),
                          end: Alignment(1.0 + 2 * t, 0),
                          colors: [
                            Colors.transparent,
                            _shimmerPrimary,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashTabletContent extends StatelessWidget {
  const _SplashTabletContent({
    required this.logoOpacity,
    required this.logoScale,
    required this.taglineOpacity,
    required this.shimmerController,
  });

  final Animation<double> logoOpacity;
  final Animation<double> logoScale;
  final Animation<double> taglineOpacity;
  final AnimationController shimmerController;

  static const Color _dotColor = Color(0xFFE0DFD8);
  static const Color _shimmerPrimary = Color(0xFF378ADD);
  static const Color _textSecondary = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _DotGridPainter(
              color: _dotColor.withValues(alpha: 0.35),
              spacing: 24,
              dotRadius: 1.5,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.secondary.withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: logoOpacity,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: logoOpacity,
                    child: ScaleTransition(
                      scale: logoScale,
                      child: child,
                    ),
                  );
                },
                child: const AuthAppLogo(fontSize: 28),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: taglineOpacity,
                child: Text(
                  'Import your dream car from anywhere in the world.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 48 + bottomInset,
          child: Center(
            child: AnimatedBuilder(
              animation: shimmerController,
              builder: (context, child) {
                final t = shimmerController.value;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: SizedBox(
                    width: 48,
                    height: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + 2 * t, 0),
                          end: Alignment(1.0 + 2 * t, 0),
                          colors: [
                            Colors.transparent,
                            _shimmerPrimary,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({
    required this.color,
    required this.spacing,
    required this.dotRadius,
  });

  final Color color;
  final double spacing;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.spacing != spacing ||
      oldDelegate.dotRadius != dotRadius;
}
