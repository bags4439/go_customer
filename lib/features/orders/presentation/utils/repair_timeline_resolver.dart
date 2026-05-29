import '../../../payments/data/models/payment_request_model.dart';
import '../../../repairs/data/models/repair_job_model.dart';
import '../../core/constants/order_timeline_constants.dart';
import 'timeline_payment_resolver.dart';

/// Derived repair phase for order timeline UI — mirrors repair screen states.
enum RepairTimelinePhase {
  noJob,
  noRepairs,
  quotePending,
  quoteSent,
  quoteDeclined,
  quoteApprovedAwaitingRequest,
  quoteApprovedDepositDue,
  quoteApprovedDepositPaid,
  inProgress,
  inProgressBalanceDue,
  inProgressBalancePaid,
  completed,
}

abstract final class RepairTimelineResolver {
  RepairTimelineResolver._();

  static PaymentRequestModel? pendingRepairPayment(
    List<PaymentRequestModel> pending,
  ) {
    return resolvePendingPaymentForStage('repair', pending);
  }

  static RepairTimelinePhase phase(
    RepairJobModel? job, {
    PaymentRequestModel? pendingPayment,
  }) {
    if (job == null) return RepairTimelinePhase.noJob;
    if (job.status == RepairStatus.notStarted && !job.optedIn) {
      return RepairTimelinePhase.noRepairs;
    }
    if (job.status == RepairStatus.notStarted) {
      return RepairTimelinePhase.quotePending;
    }
    switch (job.status) {
      case RepairStatus.quoteSent:
        return RepairTimelinePhase.quoteSent;
      case RepairStatus.quoteDeclined:
        return RepairTimelinePhase.quoteDeclined;
      case RepairStatus.quoteApproved:
        if (job.depositPaid) {
          return RepairTimelinePhase.quoteApprovedDepositPaid;
        }
        if (pendingPayment?.type == PaymentRequestType.repairFee) {
          return RepairTimelinePhase.quoteApprovedDepositDue;
        }
        return RepairTimelinePhase.quoteApprovedAwaitingRequest;
      case RepairStatus.inProgress:
        if (job.balancePaid) {
          return RepairTimelinePhase.inProgressBalancePaid;
        }
        if (pendingPayment?.type == PaymentRequestType.repairBalance) {
          return RepairTimelinePhase.inProgressBalanceDue;
        }
        return RepairTimelinePhase.inProgress;
      case RepairStatus.completed:
        return RepairTimelinePhase.completed;
      case RepairStatus.notStarted:
        return RepairTimelinePhase.quotePending;
    }
  }

  /// Summary line for the journey card when the active stage is repair.
  static String summaryDetail(
    RepairJobModel? job, {
    PaymentRequestModel? pendingPayment,
  }) {
    return switch (phase(job, pendingPayment: pendingPayment)) {
      RepairTimelinePhase.noJob =>
        OrderTimelineConstants.repairTimelineNoJobDetail,
      RepairTimelinePhase.noRepairs =>
        OrderTimelineConstants.repairNoRepairsSub,
      RepairTimelinePhase.quotePending =>
        OrderTimelineConstants.repairQuotePendingSub,
      RepairTimelinePhase.quoteSent =>
        OrderTimelineConstants.repairQuoteSentTimelineDetail,
      RepairTimelinePhase.quoteDeclined =>
        OrderTimelineConstants.repairQuoteDeclinedSub,
      RepairTimelinePhase.quoteApprovedAwaitingRequest =>
        OrderTimelineConstants.repairQuoteApprovedSub,
      RepairTimelinePhase.quoteApprovedDepositDue =>
        OrderTimelineConstants.repairDepositDueTimelineDetail,
      RepairTimelinePhase.quoteApprovedDepositPaid =>
        OrderTimelineConstants.repairDepositPaidSub,
      RepairTimelinePhase.inProgress =>
        OrderTimelineConstants.repairInProgressTimelineDetail,
      RepairTimelinePhase.inProgressBalanceDue =>
        OrderTimelineConstants.repairBalanceDueTimelineDetail,
      RepairTimelinePhase.inProgressBalancePaid =>
        OrderTimelineConstants.repairInProgressTimelineDetail,
      RepairTimelinePhase.completed =>
        OrderTimelineConstants.repairCompleteTimelineDetail,
    };
  }

  /// Pill badge on the active repair step card.
  static String activeBadge(
    RepairJobModel? job, {
    PaymentRequestModel? pendingPayment,
  }) {
    return switch (phase(job, pendingPayment: pendingPayment)) {
      RepairTimelinePhase.noJob => OrderTimelineConstants.repairBadgeAction,
      RepairTimelinePhase.noRepairs => OrderTimelineConstants.repairBadgeNoRepairs,
      RepairTimelinePhase.quotePending =>
        OrderTimelineConstants.repairBadgeAwaitingQuote,
      RepairTimelinePhase.quoteSent =>
        OrderTimelineConstants.repairBadgeReviewQuote,
      RepairTimelinePhase.quoteDeclined =>
        OrderTimelineConstants.repairBadgeDeclined,
      RepairTimelinePhase.quoteApprovedAwaitingRequest =>
        OrderTimelineConstants.repairBadgeQuoteApproved,
      RepairTimelinePhase.quoteApprovedDepositDue =>
        OrderTimelineConstants.repairBadgeDepositDue,
      RepairTimelinePhase.quoteApprovedDepositPaid =>
        OrderTimelineConstants.repairBadgeDepositPaid,
      RepairTimelinePhase.inProgress =>
        OrderTimelineConstants.repairBadgeInProgress,
      RepairTimelinePhase.inProgressBalanceDue =>
        OrderTimelineConstants.repairBadgeBalanceDue,
      RepairTimelinePhase.inProgressBalancePaid =>
        OrderTimelineConstants.repairBadgeInProgress,
      RepairTimelinePhase.completed =>
        OrderTimelineConstants.repairBadgeComplete,
    };
  }

  /// Firestore detail string written to order_timeline on buyer actions.
  static String timelineDetailForAccept() =>
      OrderTimelineConstants.repairTimelineDetailQuoteApproved;

  static String timelineDetailForDecline() =>
      OrderTimelineConstants.repairTimelineDetailQuoteDeclined;

  /// Home dashboard one-liner when order is in a repair-related status.
  static String? homeStatusLine(
    RepairJobModel? job, {
    PaymentRequestModel? pendingPayment,
  }) {
    if (job == null) return null;
    return switch (phase(job, pendingPayment: pendingPayment)) {
      RepairTimelinePhase.quoteSent =>
        OrderTimelineConstants.homeRepairQuoteSent,
      RepairTimelinePhase.quoteApprovedDepositDue =>
        OrderTimelineConstants.homeRepairDepositDue,
      RepairTimelinePhase.quoteApprovedAwaitingRequest =>
        OrderTimelineConstants.homeRepairQuoteApproved,
      RepairTimelinePhase.quoteApprovedDepositPaid =>
        OrderTimelineConstants.homeRepairDepositPaid,
      RepairTimelinePhase.inProgress =>
        OrderTimelineConstants.homeRepairInProgress,
      RepairTimelinePhase.inProgressBalanceDue =>
        OrderTimelineConstants.homeRepairBalanceDue,
      RepairTimelinePhase.completed =>
        OrderTimelineConstants.homeRepairComplete,
      _ => null,
    };
  }
}
