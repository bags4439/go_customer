import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/app_breakpoints.dart';
import 'standalone_mobile_screen_scaffold.dart';

class SimpleScreen extends StatelessWidget {
  final String title;
  final Widget? body;

  const SimpleScreen({super.key, required this.title, this.body});

  @override
  Widget build(BuildContext context) {
    final content = body ?? Center(child: Text(title));

    if (AppBreakpoints.useMobileShell(context)) {
      return StandaloneMobileScreenScaffold(
        title: title,
        onBack: () => context.pop(),
        body: content,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: content,
    );
  }
}
