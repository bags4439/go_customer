import 'package:flutter/material.dart';

import 'preferences_new_screen.dart';

class PreferencesEditScreen extends StatelessWidget {
  final String orderId;

  const PreferencesEditScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return const PreferencesNewScreen();
  }
}

