import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/web_dashboard_right_panel.dart';

/// Web home layout: main column + divider + default dashboard right panel.
class HomeWebScaffold extends StatelessWidget {
  const HomeWebScaffold({super.key, required this.appBar, required this.body});

  final PreferredSizeWidget appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: appBar,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: body),
          Container(width: 0.5, color: AppColors.borderSolid),
          const Expanded(flex: 4, child: WebDashboardRightPanel()),
        ],
      ),
    );
  }
}
