import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/document_entity.dart';
import '../models/document_model.dart';

class DocumentsFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const DocumentsFirestoreDataSource(this._firestore);

  Stream<List<DocumentEntity>> watchOrderDocuments(String orderId) {
    return _firestore
        .collection(FirestoreCollections.documents)
        .where('orderId', isEqualTo: orderId)
        .orderBy('uploadedAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => documentFromDoc(d))
            .toList());
  }

  Future<DocumentEntity?> getDocument(String documentId) async {
    final doc = await _firestore
        .collection(FirestoreCollections.documents)
        .doc(documentId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return documentFromDoc(doc);
  }
}
