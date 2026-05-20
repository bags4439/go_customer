import 'package:flutter/material.dart';
import 'package:go_customer/core/layout/app_breakpoints.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../support/presentation/widgets/support_bottom_sheet.dart';
import 'home_app_logo.dart';
import 'home_theme.dart';

/// App bar for [HomeScreen] on mobile (logo + support) and web/tablet (title).
class HomeScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeScreenAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 0.5);

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isMobile(context)) {
      return AppBar(
        backgroundColor: HomeColors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const HomeAppLogo(),
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_rounded, size: 22),
            color: AppColors.textSecondary,
            tooltip: 'Support',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.only(right: 16),
            ),
            onPressed: () => SupportBottomSheet.show(context),
          ),
        ],
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
