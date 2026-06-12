import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/layout/app_breakpoints.dart';
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

    void navigateToOnboardingIfGuest() {
      if (FirebaseAuth.instance.currentUser != null) return;
      if (!mounted) return;
      context.goNamed(RouteConstants.onboarding);
    }

    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigateToOnboardingIfGuest();
      });
    } else {
      Future<void>.delayed(const Duration(seconds: 2), navigateToOnboardingIfGuest);
    }
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

    if (AppBreakpoints.isWeb(context)) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(flex: 6, child: _SplashWebPhotoPanel()),
                    SizedBox(
                      width: 400,
                      child: _SplashWebActionPanel(
                        logoOpacity: _logoOpacity,
                        logoScale: _logoScale,
                        taglineOpacity: _taglineOpacity,
                        shimmerController: _shimmerController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppBreakpoints.isMobile(context)
          ? form
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
                    child: ScaleTransition(scale: logoScale, child: child),
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
                    child: ScaleTransition(scale: logoScale, child: child),
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

/// Left panel for web splash.
/// Full bleed photo with subtle
/// right-edge vignette and brand
/// mark at bottom centre.
class _SplashWebPhotoPanel extends StatelessWidget {
  const _SplashWebPhotoPanel();

  static const String _photo = 'assets/onboarding_preference.jpg';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        Image.asset(
          _photo,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.high,
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.08),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: .5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.directions_car_filled,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AutoImport GH',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 9,
                  letterSpacing: .5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Right panel for web splash.
/// Off-white #F5F4F0 background
/// with centred logo, tagline
/// and shimmer loading indicator.
class _SplashWebActionPanel extends StatelessWidget {
  const _SplashWebActionPanel({
    required this.logoOpacity,
    required this.logoScale,
    required this.taglineOpacity,
    required this.shimmerController,
  });

  final Animation<double> logoOpacity;
  final Animation<double> logoScale;
  final Animation<double> taglineOpacity;
  final AnimationController shimmerController;

  static const Color _shimmerColor = Color(0xFF378ADD);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: const AuthAppLogo(fontSize: 16),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: logoOpacity,
                      child: ScaleTransition(
                        scale: logoScale,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_car_filled,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: logoOpacity,
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.titleLarge.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(text: 'AutoImport '),
                            TextSpan(
                              text: 'GH',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: taglineOpacity,
                      child: Text(
                        'Import your dream car from anywhere in the world.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    AnimatedBuilder(
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
                                    _shimmerColor,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
