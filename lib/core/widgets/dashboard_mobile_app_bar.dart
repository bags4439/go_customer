import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../layout/app_breakpoints.dart';
import '../layout/dashboard_layout.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// App bar background for the mobile shell (surface gutters + white column).
Color dashboardMobileAppBarBackground(BuildContext context) {
  if (AppBreakpoints.useMobileShell(context)) {
    return AppColors.surface;
  }
  return AppColors.background;
}

/// Aligns app bar content to the mobile-shell white content column.
class DashboardAppBarToolbar extends StatelessWidget {
  const DashboardAppBarToolbar({
    super.key,
    required this.leading,
    this.actions = const [],
  });

  final Widget leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    if (!AppBreakpoints.useMobileShell(context)) {
      return leading;
    }

    final portraitTablet = DashboardLayout.isPortraitTablet(context);

    final toolbar = Row(
      children: [
        Expanded(child: leading),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 8),
          ...actions,
        ],
      ],
    );

    final inset = const EdgeInsets.symmetric(
      horizontal: DashboardLayout.mobileHorizontalInset,
    );

    if (portraitTablet) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: DashboardLayout.contentMaxWidth,
          ),
          child: Padding(padding: inset, child: toolbar),
        ),
      );
    }

    return Padding(padding: inset, child: toolbar);
  }
}

/// Icon control on a white chip — used in the mobile-shell app bar.
class DashboardAppBarIconButton extends StatelessWidget {
  const DashboardAppBarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconColor = AppColors.textSecondary,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!AppBreakpoints.useMobileShell(context)) {
      return IconButton(
        icon: Icon(icon, size: 22, color: iconColor),
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.only(right: 8),
        ),
      );
    }

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        minimumSize: Size(size, size),
        maximumSize: Size(size, size),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

/// Standard mobile-shell app bar with optional back control, surface background,
/// and content-column-aligned toolbar.
class DashboardMobileTitleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DashboardMobileTitleAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const [],
    this.titleStyle,
    this.bottomBorderColor = AppColors.borderSolid,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final TextStyle? titleStyle;
  final Color bottomBorderColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 0.5);

  @override
  Widget build(BuildContext context) {
    final useMobileShell = AppBreakpoints.useMobileShell(context);
    final titleWidget = Text(
      title,
      style: titleStyle ??
          AppTextStyles.appBarTitle.copyWith(
            color: AppColors.textPrimary,
            height: 1.0,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return AppBar(
      backgroundColor: dashboardMobileAppBarBackground(context),
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: useMobileShell ? 0 : (onBack == null ? 20 : 16),
      leading: useMobileShell || onBack == null
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: onBack,
            ),
      title: useMobileShell
          ? DashboardAppBarToolbar(
              leading: onBack == null
                  ? titleWidget
                  : Row(
                      children: [
                        DashboardAppBarIconButton(
                          icon: Icons.arrow_back_ios_new,
                          onPressed: onBack!,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: titleWidget),
                      ],
                    ),
              actions: actions,
            )
          : titleWidget,
      actions: useMobileShell ? const [] : actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: bottomBorderColor),
      ),
    );
  }
}

/// Title style used by order-flow style screens (DM Sans 17 w600).
TextStyle dashboardMobileFlowTitleStyle() {
  return GoogleFonts.dmSans(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
