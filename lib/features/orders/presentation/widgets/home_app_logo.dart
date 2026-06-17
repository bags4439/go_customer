import 'package:flutter/material.dart';

import '../../../../core/widgets/app_logo.dart';

class HomeAppLogo extends StatelessWidget {
  const HomeAppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo(style: AppLogoStyle.compact);
  }
}
