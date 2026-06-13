import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/web_dashboard_right_panel.dart';

class WebAppBody extends StatelessWidget {
  final Widget body;
  final Widget? rightPanel;
  final String pageTitle;
  final VoidCallback? onBack;
  final List<Widget> appBarActions;

  /// When false, [body] fills the content area with no right column.
  final bool showRightPanel;

  const WebAppBody({
    super.key,
    required this.body,
    this.rightPanel,
    required this.pageTitle,
    this.onBack,
    this.appBarActions = const [],
    this.showRightPanel = true,
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
        leading: onBack == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: onBack,
              ),
        titleSpacing: 20,
        centerTitle: false,
        title: Text(pageTitle, style: AppTextStyles.appBarTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.borderSolid),
        ),
        actions: appBarActions,
      ),
      body: showRightPanel
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: body),
                Container(width: 0.5, color: AppColors.borderSolid),
                Expanded(
                  flex: 4,
                  child: rightPanel ?? const WebDashboardRightPanel(),
                ),
              ],
            )
          : body,
    );
  }
}
