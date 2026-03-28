import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/route_constants.dart';
import '../widgets/auth_visual_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.search,
      iconColor: Color(0xFF234A83),
      title: 'Tell us what you want',
      subtitle:
          'Just tell us the car you want - make, model, condition and budget.',
    ),
    _SlideData(
      icon: Icons.person,
      iconColor: Color(0xFF0F6A25),
      title: 'Your personal agent',
      subtitle:
          'A dedicated agent searches US auctions on your behalf and sends you the best options.',
    ),
    _SlideData(
      icon: Icons.directions_boat_filled,
      iconColor: Color(0xFF8C6B00),
      title: 'We handle the journey',
      subtitle:
          'From shipping and duty to port clearance and repairs - track every step.',
    ),
    _SlideData(
      icon: Icons.check,
      iconColor: Color(0xFF378ADD),
      title: 'Road ready',
      subtitle:
          'When your car is ready, we deliver it to you. Your agent is with you every step.',
    ),
  ];

  Color _accentForIndex(int i) {
    switch (i) {
      case 0:
        return const Color(0xFF234A83);
      case 1:
        return const Color(0xFF0F6A25);
      case 2:
        return const Color(0xFF8C6B00);
      default:
        return const Color(0xFF378ADD);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _slides.length - 1) {
      context.goNamed(RouteConstants.register);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForIndex(_index);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accent.withValues(alpha: 0.06), Colors.white],
                stops: const [0.0, 0.5],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AuthAppLogo(fontSize: 22),
                      TextButton(
                        onPressed: () => context.goNamed(RouteConstants.login),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF378ADD),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) {
                      final item = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _OnboardingIconEntrance(
                              key: ValueKey<int>(index),
                              icon: item.icon,
                              iconColor: item.iconColor,
                            ),
                            const SizedBox(height: 32),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                item.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A18),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                item.subtitle,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF666666),
                                  height: 1.55,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (index) {
                          final active = _index == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: active ? 24 : 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF378ADD)
                                  : const Color(0xFFE0DFD8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF378ADD),
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: Text(
                            _index == _slides.length - 1
                                ? 'Create account'
                                : 'Continue',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              context.goNamed(RouteConstants.login),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _index == _slides.length - 1
                                ? 'Already have an account? Sign in'
                                : 'Skip for now',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF666666),
                            ),
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
      ),
    );
  }
}

class _OnboardingIconEntrance extends StatefulWidget {
  final IconData icon;
  final Color iconColor;

  const _OnboardingIconEntrance({
    super.key,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<_OnboardingIconEntrance> createState() =>
      _OnboardingIconEntranceState();
}

class _OnboardingIconEntranceState extends State<_OnboardingIconEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        return Opacity(
          opacity: _t.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _t.value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: widget.iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(widget.icon, size: 44, color: widget.iconColor),
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _SlideData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}
