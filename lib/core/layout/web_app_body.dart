import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/web_dashboard_right_panel.dart';

class WebAppBody extends StatelessWidget {
  final Widget body;
  final Widget? rightPanel;
  final String pageTitle;
  final List<Widget> appBarActions;

  const WebAppBody({
    super.key,
    required this.body,
    this.rightPanel,
    required this.pageTitle,
    this.appBarActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        centerTitle: false,
        title: Text(pageTitle, style: AppTextStyles.appBarTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.borderSolid),
        ),
        actions: appBarActions,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: body),
          Container(width: 0.5, color: AppColors.borderSolid),
          Expanded(flex: 4, child: rightPanel ?? WebDashboardRightPanel()),
        ],
      ),
    );
  }
}
