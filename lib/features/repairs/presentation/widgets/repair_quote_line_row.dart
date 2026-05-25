import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class RepairQuoteLineRow extends StatelessWidget {
  const RepairQuoteLineRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.cardLabel),
        const SizedBox(width: 16),
        Flexible(child: Text(value, style: AppTextStyles.cardLabel)),
      ],
    );
  }
}
