import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../repairs/presentation/providers/repair_providers.dart';
import '../../data/datasources/documents_firestore_data_source.dart';
import '../../domain/entities/document_entity.dart';
import '../models/document_list_item.dart';
import '../models/document_progress.dart';

const Set<String> _progressDocTypes = {
  'ghana_id',
  'vehicle_title',
  'payment_receipt',
  'bill_of_lading',
  'gra_declaration',
  'duty_receipt',
  'insurance_certificate',
};

const Map<String, List<String>> _sectionDocTypes = {
  'yourDocuments': ['ghana_id'],
  'vehicleAndPurchase': [
    'vehicle_title',
    'payment_receipt',
    'bill_of_lading',
    'commercial_invoice',
    'packing_list',
  ],
  'customsAndClearance': ['gra_declaration', 'duty_receipt'],
  'repairs': ['repair_quote', 'repair_receipt'],
  'delivery': ['insurance_certificate', 'delivery_note'],
};

final documentsDataSourceProvider = Provider<DocumentsFirestoreDataSource>((ref) {
  return DocumentsFirestoreDataSource(ref.watch(firestoreProvider));
});

final orderDocumentsProvider =
    StreamProvider.family<List<DocumentEntity>, String>((ref, orderId) {
  return ref.watch(documentsDataSourceProvider).watchOrderDocuments(orderId);
});

final documentProgressProvider =
    Provider.family<DocumentProgress, String>((ref, orderId) {
  final asyncList = ref.watch(orderDocumentsProvider(orderId));
  final list = asyncList.valueOrNull ?? [];
  final Set<String> readyTypes = {};
  for (final doc in list) {
    if (_progressDocTypes.contains(doc.docType) &&
        (doc.status == 'verified' || doc.status == 'pending')) {
      readyTypes.add(doc.docType);
    }
  }
  const total = 7;
  final count = readyTypes.length;
  return DocumentProgress(
    readyCount: count,
    totalExpected: total,
    fraction: total > 0 ? count / total : 0.0,
  );
});

final documentDetailProvider =
    FutureProvider.family<DocumentEntity?, String>((ref, documentId) {
  return ref.watch(documentsDataSourceProvider).getDocument(documentId);
});

final repairSectionVisibleProvider =
    FutureProvider.family<bool, String>((ref, orderId) async {
  final repairOptedIn = await ref.watch(carPreferencesRepairOptedInProvider(orderId).future);
  if (repairOptedIn == true) return true;
  final docs = await ref.watch(orderDocumentsProvider(orderId).future);
  return docs.any((d) => d.docType == 'repair_quote' || d.docType == 'repair_receipt');
});

String _availableAfterLabel(String docType) {
  const labels = {
    'vehicle_title': 'After bid is won',
    'payment_receipt': 'After payment is made',
    'bill_of_lading': 'After shipping is booked',
    'commercial_invoice': 'After shipping is booked',
    'packing_list': 'After shipping is booked',
    'gra_declaration': 'After arrival at Tema port',
    'duty_receipt': 'After duty is paid',
    'repair_quote': 'After repair is arranged',
    'repair_receipt': 'After repairs are complete',
    'insurance_certificate': 'Before delivery',
    'delivery_note': 'On delivery',
  };
  return labels[docType] ?? 'As your order progresses';
}

final documentsBySectionProvider =
    Provider.family<Map<String, List<DocumentListItem>>, String>((ref, orderId) {
  final asyncDocs = ref.watch(orderDocumentsProvider(orderId));
  final docs = asyncDocs.valueOrNull ?? [];
  final repairVisible = ref.watch(repairSectionVisibleProvider(orderId)).valueOrNull ?? false;

  final result = <String, List<DocumentListItem>>{};
  final sectionKeys = ['yourDocuments', 'vehicleAndPurchase', 'customsAndClearance'];
  if (repairVisible) sectionKeys.add('repairs');
  sectionKeys.add('delivery');

  for (final sectionKey in sectionKeys) {
    final types = _sectionDocTypes[sectionKey]!;
    final items = <DocumentListItem>[];
    for (final docType in types) {
      final existing = docs.where((d) => d.docType == docType).toList();
      if (existing.isNotEmpty) {
        for (final d in existing) {
          items.add(RealDocumentItem(d));
        }
      } else {
        final isGhanaId = docType == 'ghana_id';
        items.add(PlaceholderDocumentItem(
          docType: docType,
          availableAfterLabel: isGhanaId ? 'Upload required' : _availableAfterLabel(docType),
          isGhanaId: isGhanaId,
        ));
      }
    }
    if (items.isNotEmpty) {
      result[sectionKey] = items;
    }
  }
  return result;
});
