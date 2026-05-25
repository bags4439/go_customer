import 'package:flutter/material.dart';

import '../../../../core/models/currency_model.dart';
import '../../domain/entities/repair_job.dart';
import '../providers/repair_providers.dart';
import 'repair_awaiting_quote_state.dart';
import 'repair_choice_state.dart';
import 'repair_complete_state.dart';
import 'repair_in_progress_state.dart';
import 'repair_no_repair_state.dart';
import 'repair_not_available_state.dart';
import 'repair_quote_declined_state.dart';
import 'repair_quote_received_state.dart';

class RepairBody extends StatelessWidget {
  const RepairBody({
    super.key,
    required this.orderId,
    required this.screenState,
    required this.job,
    required this.dutyClearedAt,
    required this.currency,
    this.onOpenChat,
    this.onOpenDelivery,
  });

  final String orderId;
  final RepairScreenState screenState;
  final RepairJob? job;
  final DateTime? dutyClearedAt;
  final CurrencyModel currency;
  final VoidCallback? onOpenChat;
  final VoidCallback? onOpenDelivery;

  @override
  Widget build(BuildContext context) {
    switch (screenState) {
      case RepairScreenState.notAvailable:
        return RepairNotAvailableState(orderId: orderId);
      case RepairScreenState.choice:
        return RepairChoiceState(
          orderId: orderId,
          dutyClearedAt: dutyClearedAt,
          currency: currency,
        );
      case RepairScreenState.awaitingQuote:
        return RepairAwaitingQuoteState(
          orderId: orderId,
          onOpenChat: onOpenChat,
        );
      case RepairScreenState.quoteSent:
        return RepairQuoteReceivedState(
          orderId: orderId,
          job: job!,
          currency: currency,
          onOpenChat: onOpenChat,
        );
      case RepairScreenState.quoteDeclined:
        return RepairQuoteDeclinedState(
          orderId: orderId,
          onOpenChat: onOpenChat,
        );
      case RepairScreenState.inProgress:
        return RepairInProgressState(
          orderId: orderId,
          job: job!,
          currency: currency,
          onOpenChat: onOpenChat,
        );
      case RepairScreenState.complete:
        return RepairCompleteState(
          orderId: orderId,
          job: job!,
          currency: currency,
          onOpenDelivery: onOpenDelivery,
        );
      case RepairScreenState.noRepair:
        return RepairNoRepairState(
          orderId: orderId,
          onOpenChat: onOpenChat,
        );
    }
  }
}
