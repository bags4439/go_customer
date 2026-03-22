import '../../data/models/payment_request_model.dart';

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T e) test) {
  for (final e in items) {
    if (test(e)) return e;
  }
  return null;
}

extension PaymentRequestListX on List<PaymentRequestModel> {
  /// Pending request whose [timelineStageKey] matches [stageKey].
  PaymentRequestModel? forStage(String stageKey) => _firstWhereOrNull(
        this,
        (r) => r.timelineStageKey == stageKey && r.status == 'pending',
      );

  /// Pending request whose Firestore type string matches [type].
  PaymentRequestModel? forType(String type) => _firstWhereOrNull(
        this,
        (r) => r.type.firestoreValue == type && r.status == 'pending',
      );
}
