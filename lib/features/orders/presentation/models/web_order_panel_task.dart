/// Web order-detail right panel content (replaces full-route pushes on web).
sealed class WebOrderPanelTask {
  const WebOrderPanelTask();
}

/// Agent card, summary, quick actions.
final class WebOrderPanelDefault extends WebOrderPanelTask {
  const WebOrderPanelDefault();
}

/// Timeline step drill-down (inline sub-actions).
final class WebOrderPanelTimelineStep extends WebOrderPanelTask {
  const WebOrderPanelTimelineStep(this.stageKey);

  final String stageKey;
}

final class WebOrderPanelShipping extends WebOrderPanelTask {
  const WebOrderPanelShipping({required this.orderId});

  final String orderId;
}

final class WebOrderPanelClearance extends WebOrderPanelTask {
  const WebOrderPanelClearance({required this.orderId});

  final String orderId;
}

final class WebOrderPanelRepair extends WebOrderPanelTask {
  const WebOrderPanelRepair({required this.orderId});

  final String orderId;
}

final class WebOrderPanelDelivery extends WebOrderPanelTask {
  const WebOrderPanelDelivery({required this.orderId});

  final String orderId;
}

final class WebOrderPanelPaymentRequest extends WebOrderPanelTask {
  const WebOrderPanelPaymentRequest({
    required this.orderId,
    required this.requestId,
  });

  final String orderId;
  final String requestId;
}

final class WebOrderPanelPaymentProcessing extends WebOrderPanelTask {
  const WebOrderPanelPaymentProcessing({
    required this.orderId,
    required this.requestId,
    required this.paymentId,
  });

  final String orderId;
  final String requestId;
  final String paymentId;
}

final class WebOrderPanelPaymentConfirmed extends WebOrderPanelTask {
  const WebOrderPanelPaymentConfirmed({
    required this.orderId,
    required this.requestId,
    required this.paymentId,
  });

  final String orderId;
  final String requestId;
  final String paymentId;
}

final class WebOrderPanelReview extends WebOrderPanelTask {
  const WebOrderPanelReview({required this.orderId});

  final String orderId;
}

/// Document viewer (Documents tab).
final class WebOrderPanelDocument extends WebOrderPanelTask {
  const WebOrderPanelDocument({
    required this.orderId,
    required this.documentId,
  });

  final String orderId;
  final String documentId;
}
