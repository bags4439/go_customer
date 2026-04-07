import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/documents_firestore_data_source.dart';
import '../../domain/entities/document_entity.dart';
import '../../core/constants/document_constants.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../models/document_list_item.dart';
import '../models/document_progress.dart';

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

/// Streams all documents uploaded by the agent for this order, sorted by
/// uploadedAt descending.
final agentDocumentsProvider =
    StreamProvider.family<List<DocumentEntity>, String>((ref, orderId) {
  return ref.watch(orderDocumentsProvider(orderId)).when(
        data: (docs) {
          final filtered = docs
              .where(
                (d) =>
                    d.uploadedByRole == 'agent' && d.docType != 'ghana_id',
              )
              .toList()
            ..sort(
              (a, b) => (b.uploadedAt ?? DateTime(1970)).compareTo(
                a.uploadedAt ?? DateTime(1970),
              ),
            );
          return Stream.value(filtered);
        },
        loading: () => Stream.value(<DocumentEntity>[]),
        error: (_, __) => Stream.value(<DocumentEntity>[]),
      );
});

final documentProgressProvider = Provider.family<DocumentProgress, String>((
  ref,
  orderId,
) {
  final asyncList = ref.watch(orderDocumentsProvider(orderId));
  final list = asyncList.valueOrNull ?? [];

  final agentDocs =
      list.where((d) => d.uploadedByRole == 'agent').toList();
  final total = agentDocs.length;
  final verified =
      agentDocs.where((d) => d.status == 'verified').length;

  return DocumentProgress(
    readyCount: verified,
    totalExpected: total,
    fraction: total > 0 ? verified / total : 0.0,
  );
});

final documentDetailProvider = FutureProvider.family<DocumentEntity?, String>((
  ref,
  documentId,
) {
  return ref.watch(documentsDataSourceProvider).getDocument(documentId);
});

final documentsBySectionProvider =
    Provider.family<Map<String, List<DocumentListItem>>, String>((
  ref,
  orderId,
) {
  final userAsync = ref.watch(currentUserProfileProvider);
  final user = userAsync.valueOrNull;
  final hasIdDocument = user?.hasIdDocument ?? false;

  final items = <DocumentListItem>[];

  if (hasIdDocument) {
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

  return {
    'yourDocuments': items,
  };
});
