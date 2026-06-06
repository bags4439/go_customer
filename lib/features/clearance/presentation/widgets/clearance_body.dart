import 'package:flutter/material.dart';

import '../../../shipping/domain/entities/shipping.dart';
import '../../domain/entities/duty_clearance.dart';
import '../providers/clearance_providers.dart';
import 'clearance_agent_managed_state.dart';
import 'clearance_choice_state.dart';
import 'clearance_loading_body.dart';
import 'clearance_not_available_state.dart';
import 'clearance_self_cleared_state.dart';

class ClearanceBody extends StatelessWidget {
  const ClearanceBody({
    super.key,
    required this.orderId,
    required this.screenState,
    required this.shipping,
    required this.duty,
    this.onOpenChat,
    this.forceChoiceScreen = false,
  });

  final String orderId;
  final ClearanceScreenState screenState;
  final Shipping? shipping;
  final DutyClearance? duty;
  final VoidCallback? onOpenChat;
  final bool forceChoiceScreen;

  @override
  Widget build(BuildContext context) {
    if (forceChoiceScreen) {
      if (shipping == null) {
        return ClearanceNotAvailableState(orderId: orderId);
      }
      return ClearanceChoiceState(orderId: orderId, shipping: shipping!);
    }

    switch (screenState) {
      case ClearanceScreenState.notAvailable:
        return ClearanceNotAvailableState(orderId: orderId);
      case ClearanceScreenState.choicePending:
        if (shipping == null) {
          return ClearanceNotAvailableState(orderId: orderId);
        }
        return ClearanceChoiceState(orderId: orderId, shipping: shipping!);
      case ClearanceScreenState.agentManaged:
        if (duty == null || shipping == null) {
          return const ClearanceLoadingBody();
        }
        return ClearanceAgentManagedState(
          orderId: orderId,
          shipping: shipping!,
          duty: duty!,
        );
      case ClearanceScreenState.selfCleared:
        if (shipping == null) {
          return ClearanceNotAvailableState(orderId: orderId);
        }
        return ClearanceSelfClearedState(
          orderId: orderId,
          shipping: shipping!,
        );
    }
  }
}
