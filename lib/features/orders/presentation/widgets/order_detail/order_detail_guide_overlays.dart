import 'package:flutter/material.dart';

import 'package:go_customer/features/guide/core/constants/guide_keys.dart';
import 'package:go_customer/features/guide/presentation/widgets/coach_mark_card.dart';
import 'package:go_customer/features/guide/presentation/widgets/coach_mark_overlay.dart';
import 'package:go_customer/features/guide/presentation/widgets/guide_faq_sheet.dart';
import 'package:go_customer/features/guide/presentation/widgets/spotlight_painter.dart';

/// First-run coach marks for order detail (payment → timeline → chat → docs).
class OrderDetailGuideOverlays extends StatelessWidget {
  const OrderDetailGuideOverlays({
    super.key,
    required this.paymentCardKey,
    required this.timelineKey,
    required this.chatTabKey,
    required this.docsTabKey,
    required this.showPaymentCoach,
    required this.guideStep,
    required this.hasPendingPayment,
    required this.onPaymentDismissed,
    required this.onGuideStepChanged,
    required this.onAnimateToChatTab,
    required this.onAnimateToDocumentsTab,
  });

  final GlobalKey paymentCardKey;
  final GlobalKey timelineKey;
  final GlobalKey chatTabKey;
  final GlobalKey docsTabKey;
  final bool showPaymentCoach;
  final int guideStep;
  final bool hasPendingPayment;
  final VoidCallback onPaymentDismissed;
  final ValueChanged<int> onGuideStepChanged;
  final VoidCallback onAnimateToChatTab;
  final VoidCallback onAnimateToDocumentsTab;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showPaymentCoach && hasPendingPayment && guideStep == 0)
          CoachMarkOverlay(
            guideKey: GuideKeys.orderPaymentRequest,
            targetKey: paymentCardKey,
            title: 'Payment request from your agent',
            body:
                'Your agent sent a payment request. '
                'Review the details carefully — '
                'no money leaves your account until '
                'you approve it here.',
            spotlightShape: SpotlightShape.roundedRect,
            cardPosition: CardPosition.below,
            onDismiss: onPaymentDismissed,
            onFaqTap: () {
              onPaymentDismissed();
              GuideFaqSheet.show(context);
            },
          ),
        if (guideStep == 1 && !showPaymentCoach)
          CoachMarkOverlay(
            guideKey: GuideKeys.orderTimeline,
            targetKey: timelineKey,
            title: 'Your import journey',
            body:
                'This timeline tracks every stage '
                'from search to delivery. Tap any '
                'stage to see more details.',
            spotlightShape: SpotlightShape.roundedRect,
            onDismiss: () => onGuideStepChanged(0),
            onNext: () {
              onGuideStepChanged(2);
              onAnimateToChatTab();
            },
            onFaqTap: () {
              onGuideStepChanged(0);
              GuideFaqSheet.show(context);
            },
          ),
        if (guideStep == 2 && !showPaymentCoach)
          CoachMarkOverlay(
            guideKey: GuideKeys.chat,
            targetKey: chatTabKey,
            title: 'Chat with your agent',
            body:
                'Your dedicated agent is always '
                'available here. Ask anything — '
                'they handle everything for you.',
            spotlightShape: SpotlightShape.roundedRect,
            onDismiss: () => onGuideStepChanged(0),
            onNext: () {
              onGuideStepChanged(3);
              onAnimateToDocumentsTab();
            },
            onFaqTap: () {
              onGuideStepChanged(0);
              GuideFaqSheet.show(context);
            },
          ),
        if (guideStep == 3 && !showPaymentCoach)
          CoachMarkOverlay(
            guideKey: GuideKeys.documents,
            targetKey: docsTabKey,
            title: 'Your documents',
            body:
                'All your import papers live here '
                '— receipts, vehicle title, clearance '
                'docs and more. Always accessible.',
            spotlightShape: SpotlightShape.roundedRect,
            onDismiss: () => onGuideStepChanged(0),
            onFaqTap: () {
              onGuideStepChanged(0);
              GuideFaqSheet.show(context);
            },
          ),
      ],
    );
  }
}
