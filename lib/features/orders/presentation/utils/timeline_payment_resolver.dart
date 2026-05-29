import '../../../payments/data/models/payment_request_model.dart';

/// Resolves which pending payment request applies to a timeline [stageKey].
PaymentRequestModel? resolvePendingPaymentForStage(
  String stageKey,
  List<PaymentRequestModel> pending,
) {
  PaymentRequestModel? pick(bool Function(PaymentRequestModel r) test) {
    for (final r in pending) {
      if (r.status != 'pending') continue;
      if (test(r)) return r;
    }
    return null;
  }

  switch (stageKey) {
    case 'deposit_paid':
      return pick((r) => r.timelineStageKey == 'deposit_paid') ??
          pick((r) => r.type == PaymentRequestType.initial);
    case 'searching':
    case 'vehicle_balance':
      return pick((r) => r.timelineStageKey == 'vehicle_balance') ??
          pick((r) => r.type == PaymentRequestType.vehicleBalanceAndShipping);
    case 'shipping':
      return pick((r) => r.timelineStageKey == 'shipping');
    case 'clearance':
      return pick((r) => r.timelineStageKey == 'clearance');
    case 'repair':
      return pick(
            (r) =>
                r.timelineStageKey == 'repair' &&
                r.type == PaymentRequestType.repairFee,
          ) ??
          pick((r) => r.type == PaymentRequestType.repairFee) ??
          pick(
            (r) =>
                r.timelineStageKey == 'repair' &&
                r.type == PaymentRequestType.repairBalance,
          ) ??
          pick((r) => r.type == PaymentRequestType.repairBalance);
    case 'delivery':
      return pick((r) => r.timelineStageKey == 'delivery');
    default:
      return null;
  }
}
