/// One repair_jobs document per order (query by orderId).
class RepairJob {
  final String id;
  final String orderId;

  /// Buyer repair choice at job creation (mirrors Firestore `optedIn`).
  final bool optedIn;
  final String? garageId;
  final String? garageNameCustom;
  final String? garageLocation;
  final String? workDescription;
  final double? totalInvoiceGhs;
  final double? partsDepositGhs;
  final double? workmanshipBalanceGhs;
  final double? platformFeeGhs;
  final double? quoteGhs;
  final double? platformServiceFeeGhs;
  final double? totalQuotedGhs;
  final double? finalCostGhs;
  final bool? quoteApprovedByBuyer;
  final DateTime? quoteApprovedAt;
  final DateTime? quoteDeclinedAt;
  final String? depositPaymentRequestId;
  final String? balancePaymentRequestId;
  final bool depositPaid;
  final bool balancePaid;
  final String status;
  final DateTime? startDate;
  final DateTime? estimatedCompletion;
  final DateTime? actualCompletion;
  final List<String> beforePhotoUrls;
  final List<String> afterPhotoUrls;
  final String? notes;
  final DateTime? createdAt;

  const RepairJob({
    required this.id,
    required this.orderId,
    this.optedIn = true,
    this.garageId,
    this.garageNameCustom,
    this.garageLocation,
    this.workDescription,
    this.totalInvoiceGhs,
    this.partsDepositGhs,
    this.workmanshipBalanceGhs,
    this.platformFeeGhs,
    this.quoteGhs,
    this.platformServiceFeeGhs,
    this.totalQuotedGhs,
    this.finalCostGhs,
    this.quoteApprovedByBuyer,
    this.quoteApprovedAt,
    this.quoteDeclinedAt,
    this.depositPaymentRequestId,
    this.balancePaymentRequestId,
    this.depositPaid = false,
    this.balancePaid = false,
    required this.status,
    this.startDate,
    this.estimatedCompletion,
    this.actualCompletion,
    this.beforePhotoUrls = const [],
    this.afterPhotoUrls = const [],
    this.notes,
    this.createdAt,
  });

  bool get isQuoteSent => status == 'quote_sent';
  bool get isQuoteDeclined => status == 'quote_declined';
  bool get isQuoteApproved => status == 'quote_approved';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isNotStarted => status == 'not_started';

  /// Platform fee snapshot — prefers [platformFeeGhs], falls back to legacy field.
  double? get effectivePlatformFeeGhs =>
      platformFeeGhs ?? platformServiceFeeGhs;

  /// Garage invoice total — prefers [totalInvoiceGhs], falls back to [quoteGhs].
  double? get effectiveInvoiceGhs => totalInvoiceGhs ?? quoteGhs;

  /// Workmanship = garage invoice minus parts deposit (when both exist).
  double? get effectiveWorkmanshipGhs {
    final invoice = effectiveInvoiceGhs;
    final parts = partsDepositGhs;
    if (workmanshipBalanceGhs != null) return workmanshipBalanceGhs;
    if (invoice == null || parts == null) return null;
    return invoice - parts;
  }

  /// Request 1 total: parts deposit + platform fee.
  double? get depositDueGhs {
    final parts = partsDepositGhs;
    final fee = effectivePlatformFeeGhs;
    if (parts == null && fee == null) return null;
    return (parts ?? 0) + (fee ?? 0);
  }

  bool get hasInvoiceSplit =>
      partsDepositGhs != null && effectiveWorkmanshipGhs != null;
}
