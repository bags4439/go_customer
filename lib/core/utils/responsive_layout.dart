import 'package:flutter/material.dart';

class ResponsiveLayout {
  ResponsiveLayout._();

  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 960) return 480;
    // Portrait tablet: max width via [DashboardPortraitFrame] on the screen body.
    return double.infinity;
  }

  /// Preferences wizard / edit form: tablet 560dp, web 520dp centred.
  static double preferencesFormMaxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 960) return 520;
    if (w >= 600) return 560;
    return double.infinity;
  }

  static EdgeInsets contentPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 960) {
      return const EdgeInsets.symmetric(horizontal: 48);
    }
    if (w >= 600) {
      return const EdgeInsets.symmetric(horizontal: 40);
    }
    return const EdgeInsets.symmetric(horizontal: 24);
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 960;

  static bool isWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= 960;
}
