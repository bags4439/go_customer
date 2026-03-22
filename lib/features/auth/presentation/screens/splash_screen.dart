import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../widgets/auth_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.goNamed(RouteConstants.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const AuthShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AuthIconCircle(
            icon: Icons.directions_car_filled,
            backgroundColor: Color(0xFF234A83),
          ),
          SizedBox(height: 20),
          Text(
            'AutoImport GH',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Text(
            'Buy your dream car from the US and get it delivered to your door in Ghana.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

