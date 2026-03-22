import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../widgets/auth_shell.dart';

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
      iconColor: Color(0xFF9AA0B6),
      title: 'Road ready',
      subtitle:
          'When your car is ready, we deliver it to you. Your agent is with you every step.',
    ),
  ];

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
    final slide = _slides[_index];

    return AuthShell(
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) {
                final item = _slides[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AuthIconCircle(
                      icon: item.icon,
                      backgroundColor: item.iconColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (index) {
              final active = _index == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: active ? 22 : 8,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF378ADD) : const Color(0xFFCCD0D8),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _next,
              child: Text(_index == _slides.length - 1 ? 'Create account' : 'Next'),
            ),
          ),
          TextButton(
            onPressed: () => context.goNamed(RouteConstants.login),
            child: Text(_index == _slides.length - 1 ? 'Skip' : 'Skip'),
          ),
          const SizedBox(height: 8),
          Text(
            'Slide ${_index + 1} of ${_slides.length}: ${slide.title}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
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

