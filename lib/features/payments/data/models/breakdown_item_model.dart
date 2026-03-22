import '../../domain/entities/breakdown_item.dart';

BreakdownItem breakdownItemFromJson(Map<String, dynamic> json) {
  return BreakdownItem(
    label: (json['label'] as String?) ?? '',
    amountGhs: ((json['amountGhs'] as num?) ?? 0).toDouble(),
    amountUsd: ((json['amountUsd'] as num?) ?? 0).toDouble(),
    isDeduction: json['isDeduction'] as bool? ?? false,
  );
}

List<BreakdownItem> breakdownListFromJson(dynamic value) {
  if (value == null) return const [];
  if (value is! List) return const [];
  return (value as List)
      .map((e) => breakdownItemFromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}
