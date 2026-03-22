/// One repair_jobs document per order (query by orderId).
class RepairJob {
  final String id;
  final String orderId;
  final String? garageId;
  final String? garageNameCustom;
  final String? garageLocation;
  final String? workDescription;
  final double? quoteGhs;
  final double? platformServiceFeeGhs;
  final double? totalQuotedGhs;
  final double? finalCostGhs;
  final bool? quoteApprovedByBuyer;
  final DateTime? quoteApprovedAt;
  final DateTime? quoteDeclinedAt;
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
    this.garageId,
    this.garageNameCustom,
    this.garageLocation,
    this.workDescription,
    this.quoteGhs,
    this.platformServiceFeeGhs,
    this.totalQuotedGhs,
    this.finalCostGhs,
    this.quoteApprovedByBuyer,
    this.quoteApprovedAt,
    this.quoteDeclinedAt,
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
}
