import 'package:flutter/material.dart';
import 'package:go_customer/core/layout/app_breakpoints.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/widgets/dashboard_mobile_app_bar.dart';

import '../../../support/presentation/widgets/support_bottom_sheet.dart';
import 'home_app_logo.dart';
import 'home_theme.dart';

/// App bar for [HomeScreen] on mobile shell (logo + support) and web shell (title).
class HomeScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeScreenAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 0.5);

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.useMobileShell(context)) {
      return AppBar(
        backgroundColor: dashboardMobileAppBarBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: DashboardAppBarToolbar(
          leading: const HomeAppLogo(),
          actions: [
            DashboardAppBarIconButton(
              icon: Icons.headset_mic_rounded,
              tooltip: 'Support',
              onPressed: () => SupportBottomSheet.show(context),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: HomeColors.border),
        ),
      );
    }

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      centerTitle: false,
      title: Text('Home', style: AppTextStyles.appBarTitle),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.borderSolid),
      ),
    );
  }
}
