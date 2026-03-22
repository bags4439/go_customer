// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RepairJobModelImpl _$$RepairJobModelImplFromJson(
  Map<String, dynamic> json,
) => _$RepairJobModelImpl(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  garageId: json['garageId'] as String?,
  garageNameCustom: json['garageNameCustom'] as String?,
  garageLocation: json['garageLocation'] as String?,
  workDescription: json['workDescription'] as String?,
  invoiceImageUrl: json['invoiceImageUrl'] as String?,
  invoiceRefNumber: json['invoiceRefNumber'] as String?,
  invoiceDate: _dateTimeFromJson(json['invoiceDate']),
  totalInvoiceGhs: (json['totalInvoiceGhs'] as num?)?.toDouble(),
  partsDepositGhs: (json['partsDepositGhs'] as num?)?.toDouble(),
  workmanshipBalanceGhs: (json['workmanshipBalanceGhs'] as num?)?.toDouble(),
  platformFeeGhs: (json['platformFeeGhs'] as num?)?.toDouble(),
  quoteGhs: (json['quoteGhs'] as num?)?.toDouble(),
  platformServiceFeeGhs: (json['platformServiceFeeGhs'] as num?)?.toDouble(),
  totalQuotedGhs: (json['totalQuotedGhs'] as num?)?.toDouble(),
  finalCostGhs: (json['finalCostGhs'] as num?)?.toDouble(),
  quoteApprovedByBuyer: json['quoteApprovedByBuyer'] as bool? ?? false,
  quoteApprovedAt: json['quoteApprovedAt'] == null
      ? null
      : DateTime.parse(json['quoteApprovedAt'] as String),
  quoteDeclinedAt: json['quoteDeclinedAt'] == null
      ? null
      : DateTime.parse(json['quoteDeclinedAt'] as String),
  depositPaymentRequestId: json['depositPaymentRequestId'] as String?,
  balancePaymentRequestId: json['balancePaymentRequestId'] as String?,
  depositPaid: json['depositPaid'] as bool? ?? false,
  balancePaid: json['balancePaid'] as bool? ?? false,
  status: json['status'] == null
      ? RepairStatus.notStarted
      : _repairStatusFromJson(json['status']),
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  estimatedCompletion: json['estimatedCompletion'] == null
      ? null
      : DateTime.parse(json['estimatedCompletion'] as String),
  actualCompletion: json['actualCompletion'] == null
      ? null
      : DateTime.parse(json['actualCompletion'] as String),
  beforePhotoUrlsJson: _stringListFromJson(json['beforePhotoUrlsJson']),
  afterPhotoUrlsJson: _stringListFromJson(json['afterPhotoUrlsJson']),
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$RepairJobModelImplToJson(
  _$RepairJobModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'garageId': instance.garageId,
  'garageNameCustom': instance.garageNameCustom,
  'garageLocation': instance.garageLocation,
  'workDescription': instance.workDescription,
  'invoiceImageUrl': instance.invoiceImageUrl,
  'invoiceRefNumber': instance.invoiceRefNumber,
  'invoiceDate': _dateTimeToJson(instance.invoiceDate),
  'totalInvoiceGhs': instance.totalInvoiceGhs,
  'partsDepositGhs': instance.partsDepositGhs,
  'workmanshipBalanceGhs': instance.workmanshipBalanceGhs,
  'platformFeeGhs': instance.platformFeeGhs,
  'quoteGhs': instance.quoteGhs,
  'platformServiceFeeGhs': instance.platformServiceFeeGhs,
  'totalQuotedGhs': instance.totalQuotedGhs,
  'finalCostGhs': instance.finalCostGhs,
  'quoteApprovedByBuyer': instance.quoteApprovedByBuyer,
  'quoteApprovedAt': instance.quoteApprovedAt?.toIso8601String(),
  'quoteDeclinedAt': instance.quoteDeclinedAt?.toIso8601String(),
  'depositPaymentRequestId': instance.depositPaymentRequestId,
  'balancePaymentRequestId': instance.balancePaymentRequestId,
  'depositPaid': instance.depositPaid,
  'balancePaid': instance.balancePaid,
  'status': _repairStatusToJson(instance.status),
  'startDate': instance.startDate?.toIso8601String(),
  'estimatedCompletion': instance.estimatedCompletion?.toIso8601String(),
  'actualCompletion': instance.actualCompletion?.toIso8601String(),
  'beforePhotoUrlsJson': _stringListToJson(instance.beforePhotoUrlsJson),
  'afterPhotoUrlsJson': _stringListToJson(instance.afterPhotoUrlsJson),
  'notes': instance.notes,
  'createdAt': instance.createdAt?.toIso8601String(),
};
