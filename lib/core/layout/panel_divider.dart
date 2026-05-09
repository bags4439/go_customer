import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Subtle shadow-based panel
/// divider for web layouts.
class PanelDivider extends StatelessWidget {
  const PanelDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.borderSolid, width: .5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.panelShadow,
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
    );
  }
}
