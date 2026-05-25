import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class ShippingDetailRow extends StatelessWidget {
  const ShippingDetailRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.cardLabel),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.cardValue,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
