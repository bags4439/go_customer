import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Firebase Storage uploads for buyer identity documents (Ghana Card / passport).
class IdDocumentStorage {
  const IdDocumentStorage(this._storage);

  final FirebaseStorage _storage;

  static String normalizeExtension(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    return switch (ext) {
      'jpeg' => 'jpg',
      'jpg' || 'png' || 'pdf' => ext,
      _ => 'jpg',
    };
  }

  static String extensionFromLocalPath(String localFilePath) {
    final dot = localFilePath.lastIndexOf('.');
    if (dot <= 0 || dot == localFilePath.length - 1) return 'jpg';
    return normalizeExtension(localFilePath.substring(dot + 1));
  }

  static String contentTypeForExtension(String extension) {
    return switch (normalizeExtension(extension)) {
      'png' => 'image/png',
      'pdf' => 'application/pdf',
      _ => 'image/jpeg',
    };
  }

  /// Uploads to `users/{userId}/id_document.{ext}` and returns the download URL.
  Future<String> upload({
    required String userId,
    required String localFilePath,
    required String extension,
  }) async {
    final ext = normalizeExtension(extension);
    final storagePath = 'users/$userId/id_document.$ext';
    final ref = _storage.ref().child(storagePath);

    final xFile = XFile(localFilePath);
    final bytes = await xFile.readAsBytes();
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentTypeForExtension(ext)),
    );
    return ref.getDownloadURL();
  }
}
