import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum CardContainerPaddingType { none, small, medium, large, xlarge }

class CardContainer extends StatelessWidget {
  final Widget child;
  final CardContainerPaddingType paddingType;

  const CardContainer({
    super.key,
    required this.child,
    this.paddingType = CardContainerPaddingType.small,
  });

  @override
  Widget build(BuildContext context) {
    double padding = paddingType == CardContainerPaddingType.small
        ? 4
        : paddingType == CardContainerPaddingType.medium
        ? 8
        : paddingType == CardContainerPaddingType.large
        ? 12
        : paddingType == CardContainerPaddingType.xlarge
        ? 16
        : 0;
    return Container(
      padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
