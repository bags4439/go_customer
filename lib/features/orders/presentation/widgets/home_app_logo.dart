import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import 'home_theme.dart';

class HomeAppLogo extends StatelessWidget {
  const HomeAppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: HomeColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.directions_car_filled,
            color: Colors.white,
            size: 17,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'AutoImport',
          style: AppTextStyles.appBarTitle.copyWith(
            color: HomeColors.textPrimary,
          ),
        ),
        Text(
          ' GH',
          style: AppTextStyles.appBarTitle.copyWith(color: HomeColors.primary),
        ),
      ],
    );
  }
}
