import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class ClearanceInfoRow extends StatelessWidget {
  const ClearanceInfoRow({
    super.key,
    required this.icon,
    required this.text,
    required this.visible,
  });

  final String icon;
  final String text;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodySmall.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
