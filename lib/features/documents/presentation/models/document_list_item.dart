import '../../domain/entities/document_entity.dart';

/// One item in a section: either a real document or a placeholder.
sealed class DocumentListItem {
  const DocumentListItem();
}

final class RealDocumentItem extends DocumentListItem {
  final DocumentEntity document;
  const RealDocumentItem(this.document);
}

final class PlaceholderDocumentItem extends DocumentListItem {
  final String docType;
  final String availableAfterLabel;
  final bool isGhanaId;
  const PlaceholderDocumentItem({
    required this.docType,
    required this.availableAfterLabel,
    this.isGhanaId = false,
  });
}
