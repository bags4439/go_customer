/// Payment document — created on initiate, updated by Cloud Function after Paystack webhook.
class Payment {
  final String id;
  final String orderId;
  final String buyerId;
  final String paymentRequestId;
  final String type;
  final String? description;
  final double amountGhs;
  final double amountUsd;
  final double exchangeRate;
  final String method;
  final String provider;
  final String? providerRef;
  final String status;
  final DateTime? initiatedAt;
  final DateTime? confirmedAt;
  final DateTime? refundedAt;

  const Payment({
    required this.id,
    required this.orderId,
    required this.buyerId,
    required this.paymentRequestId,
    required this.type,
    this.description,
    required this.amountGhs,
    required this.amountUsd,
    required this.exchangeRate,
    required this.method,
    required this.provider,
    this.providerRef,
    required this.status,
    this.initiatedAt,
    this.confirmedAt,
    this.refundedAt,
  });

  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending' || status == 'processing';
}
