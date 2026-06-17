import 'package:flutter/material.dart';

import '../../../../core/widgets/app_logo.dart';

/// Logo for the brand-colour launch screen (native splash handoff).
class LaunchBrandLogo extends StatelessWidget {
  const LaunchBrandLogo({super.key, this.fontSize = 28});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return AppLogo(fontSize: fontSize, style: AppLogoStyle.onBrand);
  }
}
