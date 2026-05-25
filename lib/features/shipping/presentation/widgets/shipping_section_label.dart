import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class ShippingSectionLabel extends StatelessWidget {
  const ShippingSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.sectionLabel);
  }
}
