import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/datasources/documents_firestore_data_source.dart';
import '../../domain/entities/document_entity.dart';
import '../../core/constants/document_constants.dart';
import '../models/document_list_item.dart';
import '../models/document_progress.dart';

/// Returns the document types to show per section
/// based on the order's purchase origin and vehicle type.
Map<String, List<String>> _sectionDocTypesForOrder(
  String purchaseOrigin,
  bool isNewVehicle,
) {
  final vehicleAndPurchase = (purchaseOrigin == 'china' || isNewVehicle)
      ? [
          'commercial_invoice',
          'payment_receipt',
          'bill_of_lading',
          'packing_list',
        ]
      : [
          'vehicle_title',
          'payment_receipt',
          'bill_of_lading',
          'commercial_invoice',
          'packing_list',
        ];

  return {
    'yourDocuments': ['ghana_id'],
    'vehicleAndPurchase': vehicleAndPurchase,
    'customsAndClearance': ['gra_declaration', 'duty_receipt'],
    'repairs': ['repair_quote', 'repair_receipt'],
    'delivery': ['insurance_certificate', 'delivery_note'],
  };
}

Set<String> _progressDocTypesForOrder(
  String purchaseOrigin,
  bool isNewVehicle,
) {
  final base = <String>{
    'ghana_id',
    'payment_receipt',
    'bill_of_lading',
    'gra_declaration',
    'duty_receipt',
    'insurance_certificate',
  };

  if (purchaseOrigin == 'china' || isNewVehicle) {
    base.add('commercial_invoice');
  } else {
    base.add('vehicle_title');
  }

  return base;
}

String _availableAfterLabelForOrder(
  String docType,
  String purchaseOrigin,
  bool isNewVehicle,
) {
  final isChina = purchaseOrigin == 'china' || isNewVehicle;

  return switch (docType) {
    'vehicle_title' =>
      isChina
          ? DocumentConstants.afterVehicleConfirmed
          : DocumentConstants.afterBidWon,
    'payment_receipt' => DocumentConstants.afterPaymentMade,
    'bill_of_lading' => DocumentConstants.afterShippingBooked,
    'commercial_invoice' =>
      isChina
          ? DocumentConstants.afterOrderPlaced
          : DocumentConstants.afterShippingBooked,
    'packing_list' => DocumentConstants.afterShippingBooked,
    'gra_declaration' => DocumentConstants.afterArrivalTema,
    'duty_receipt' => DocumentConstants.afterDutyPaid,
    'repair_quote' => DocumentConstants.afterRepairArranged,
    'repair_receipt' => DocumentConstants.afterRepairsComplete,
    'insurance_certificate' => DocumentConstants.beforeDelivery,
    'delivery_note' => DocumentConstants.onDelivery,
    _ => DocumentConstants.availableAsOrderProgresses,
  };
}

final documentsDataSourceProvider = Provider<DocumentsFirestoreDataSource>((
  ref,
) {
  return DocumentsFirestoreDataSource(ref.watch(firestoreProvider));
});

final orderDocumentsProvider =
    StreamProvider.family<List<DocumentEntity>, String>((ref, orderId) {
      return ref
          .watch(documentsDataSourceProvider)
          .watchOrderDocuments(orderId);
    });

final documentProgressProvider = Provider.family<DocumentProgress, String>((
  ref,
  orderId,
) {
  final asyncList = ref.watch(orderDocumentsProvider(orderId));
  final list = asyncList.valueOrNull ?? [];

  final orderAsync = ref.watch(orderProvider(orderId));
  final order = orderAsync.valueOrNull;
  final purchaseOrigin = order?.purchaseOrigin ?? 'any';
  final isNewVehicle = order?.isNewVehicle ?? false;

  final progressTypes = _progressDocTypesForOrder(purchaseOrigin, isNewVehicle);
  final total = progressTypes.length;

  final Set<String> readyTypes = {};
  for (final doc in list) {
    if (progressTypes.contains(doc.docType) &&
        (doc.status == 'verified' || doc.status == 'pending')) {
      readyTypes.add(doc.docType);
    }
  }

  final count = readyTypes.length;
  return DocumentProgress(
    readyCount: count,
    totalExpected: total,
    fraction: total > 0 ? count / total : 0.0,
  );
});

final documentDetailProvider = FutureProvider.family<DocumentEntity?, String>((
  ref,
  documentId,
) {
  return ref.watch(documentsDataSourceProvider).getDocument(documentId);
});

final repairSectionVisibleProvider = Provider.family<bool, String>((
  ref,
  orderId,
) {
  final orderAsync = ref.watch(orderProvider(orderId));
  final order = orderAsync.valueOrNull;
  if (order?.repairOptedIn == true) return true;

  final asyncDocs = ref.watch(orderDocumentsProvider(orderId));
  final docs = asyncDocs.valueOrNull ?? [];
  return docs.any(
    (d) => d.docType == 'repair_quote' || d.docType == 'repair_receipt',
  );
});

final documentsBySectionProvider =
    Provider.family<Map<String, List<DocumentListItem>>, String>((
      ref,
      orderId,
    ) {
      final asyncDocs = ref.watch(orderDocumentsProvider(orderId));
      final docs = asyncDocs.valueOrNull ?? [];

      final orderAsync = ref.watch(orderProvider(orderId));
      final order = orderAsync.valueOrNull;
      final purchaseOrigin = order?.purchaseOrigin ?? 'any';
      final isNewVehicle = order?.isNewVehicle ?? false;

      final repairVisible = ref.watch(repairSectionVisibleProvider(orderId));

      final userAsync = ref.watch(currentUserProfileProvider);
      final user = userAsync.valueOrNull;
      final hasGhanaCard = user?.hasGhanaCard ?? false;

      final sectionDocTypes = _sectionDocTypesForOrder(
        purchaseOrigin,
        isNewVehicle,
      );

      final sectionKeys = [
        'yourDocuments',
        'vehicleAndPurchase',
        'customsAndClearance',
      ];
      if (repairVisible) sectionKeys.add('repairs');
      sectionKeys.add('delivery');

      final result = <String, List<DocumentListItem>>{};

      for (final sectionKey in sectionKeys) {
        final types = sectionDocTypes[sectionKey]!;
        final items = <DocumentListItem>[];

        for (final docType in types) {
          final existing = docs.where((d) => d.docType == docType).toList();

          if (docType == 'ghana_id') {
            if (hasGhanaCard) {
              items.add(
                PlaceholderDocumentItem(
                  docType: 'ghana_id',
                  availableAfterLabel: DocumentConstants.ghanaCardOnFileShort,
                  isGhanaId: true,
                  isGhanaIdProvided: true,
                ),
              );
            } else {
              items.add(
                PlaceholderDocumentItem(
                  docType: 'ghana_id',
                  availableAfterLabel: DocumentConstants.uploadRequired,
                  isGhanaId: true,
                  isGhanaIdProvided: false,
                ),
              );
            }
            continue;
          }

          if (existing.isNotEmpty) {
            for (final d in existing) {
              items.add(RealDocumentItem(d));
            }
          } else {
            items.add(
              PlaceholderDocumentItem(
                docType: docType,
                availableAfterLabel: _availableAfterLabelForOrder(
                  docType,
                  purchaseOrigin,
                  isNewVehicle,
                ),
                isGhanaId: false,
                isGhanaIdProvided: false,
              ),
            );
          }
        }

        if (items.isNotEmpty) {
          result[sectionKey] = items;
        }
      }

      return result;
    });
