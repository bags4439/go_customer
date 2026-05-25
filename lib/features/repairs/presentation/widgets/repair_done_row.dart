import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../core/constants/repair_constants.dart';

class RepairDoneRow extends StatelessWidget {
  const RepairDoneRow({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.cardLabel,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            RepairConstants.doneLabel,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
