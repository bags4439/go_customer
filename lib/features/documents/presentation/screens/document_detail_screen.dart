import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/styled_snackbar.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../core/constants/document_constants.dart';
import '../../domain/entities/document_entity.dart';
import '../providers/documents_providers.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final String orderId;
  final String documentId;

  const DocumentDetailScreen({
    super.key,
    required this.orderId,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docAsync = ref.watch(documentDetailProvider(documentId));
    final orderAsync = ref.watch(orderProvider(orderId));

    return docAsync.when(
      data: (document) {
        if (document == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Document')),
            body: const Center(child: Text('Document not found')),
          );
        }
        final orderRef = orderAsync.valueOrNull?.orderRef ?? orderId;
        return _DocumentDetailContent(
          document: document,
          orderRef: orderRef,
        );
      },
      loading: () => _DocumentDetailLoading(),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Document')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DocumentConstants.errorLoadDocuments),
              TextButton(
                onPressed: () => ref.invalidate(documentDetailProvider(documentId)),
                child: const Text(DocumentConstants.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentDetailContent extends ConsumerStatefulWidget {
  final DocumentEntity document;
  final String orderRef;

  const _DocumentDetailContent({
    required this.document,
    required this.orderRef,
  });

  @override
  ConsumerState<_DocumentDetailContent> createState() => _DocumentDetailContentState();
}

class _DocumentDetailContentState extends ConsumerState<_DocumentDetailContent> {
  bool _downloadInProgress = false;
  bool _shareInProgress = false;

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final statusLabel = doc.status == 'verified'
        ? DocumentConstants.statusVerified
        : doc.status == 'pending'
            ? DocumentConstants.statusPending
            : DocumentConstants.statusRejected;
    final statusBg = doc.status == 'verified'
        ? const Color(0xFFEAF3DE)
        : doc.status == 'pending'
            ? const Color(0xFFFAEEDA)
            : const Color(0xFFFCEBEB);
    final statusFg = doc.status == 'verified'
        ? const Color(0xFF27500A)
        : doc.status == 'pending'
            ? const Color(0xFF633806)
            : const Color(0xFFA32D2D);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          doc.label,
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: const Color(0xFFE0DFD8),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: statusFg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _PreviewArea(document: doc, storage: ref.read(storageProvider)),
          const SizedBox(height: 16),
          _MetadataCard(document: doc, orderRef: widget.orderRef),
          if (doc.isRejected) ...[
            const SizedBox(height: 16),
            _RejectionReasonCard(
              reason: doc.rejectionReason,
              orderId: doc.orderId,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.download_outlined,
                  label: DocumentConstants.download,
                  inProgress: _downloadInProgress,
                  onTap: doc.fileUrl != null
                      ? () => _onDownload(context)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.share_outlined,
                  label: DocumentConstants.share,
                  inProgress: _shareInProgress,
                  onTap: doc.fileUrl != null
                      ? () => _onShare(context)
                      : null,
                ),
              ),
            ],
          ),
          if (doc.uploadedByRole == 'buyer' && doc.isRejected) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/profile/id-verification'),
              child: Text(DocumentConstants.reUpload),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _onDownload(BuildContext context) async {
    setState(() => _downloadInProgress = true);
    try {
      final storage = ref.read(storageProvider);
      final storageRef = storage.ref(widget.document.fileUrl!);
      final url = await storageRef.getDownloadURL();
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception('Download failed');
      final dir = await getApplicationDocumentsDirectory();
      final ext = widget.document.fileType ?? 'bin';
      final file = File('${dir.path}/document_${widget.document.id}.$ext');
      await file.writeAsBytes(response.bodyBytes);
      await OpenFile.open(file.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              DocumentConstants.fileSavedToDownloads,
              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A1A18),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        showErrorSnackBar(
          context,
          DocumentConstants.downloadFailed,
          actionLabel: DocumentConstants.retry,
          onAction: () => _onDownload(context),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadInProgress = false);
    }
  }

  Future<void> _onShare(BuildContext context) async {
    setState(() => _shareInProgress = true);
    try {
      final storage = ref.read(storageProvider);
      final storageRef = storage.ref(widget.document.fileUrl!);
      final url = await storageRef.getDownloadURL();
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception('Share failed');
      final dir = await getTemporaryDirectory();
      final ext = widget.document.fileType ?? 'bin';
      final file = File('${dir.path}/share_${widget.document.id}.$ext');
      await file.writeAsBytes(response.bodyBytes);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (_) {
      if (context.mounted) {
        showErrorSnackBar(context, DocumentConstants.shareFailed);
      }
    } finally {
      if (mounted) setState(() => _shareInProgress = false);
    }
  }
}

class _PreviewArea extends StatefulWidget {
  final DocumentEntity document;
  final FirebaseStorage storage;

  const _PreviewArea({required this.document, required this.storage});

  @override
  State<_PreviewArea> createState() => _PreviewAreaState();
}

class _PreviewAreaState extends State<_PreviewArea> {
  String? _downloadUrl;
  bool _loadFailed = false;

  static const Set<String> _imageTypes = {'jpg', 'jpeg', 'png', 'webp'};

  @override
  void initState() {
    super.initState();
    if (widget.document.fileUrl != null) {
      _fetchUrl();
    }
  }

  Future<void> _fetchUrl() async {
    try {
      final url = await widget.storage.ref(widget.document.fileUrl!).getDownloadURL();
      if (mounted) setState(() { _downloadUrl = url; _loadFailed = false; });
    } catch (_) {
      if (mounted) setState(() { _loadFailed = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final fileType = doc.fileType?.toLowerCase() ?? '';
    final isPdf = fileType == 'pdf';
    final isImage = _imageTypes.contains(fileType);

    if (doc.fileUrl == null) {
      return _buildUnknownPreview(context);
    }

    if (_loadFailed) {
      return _buildErrorPreview(context);
    }

    if (_downloadUrl == null) {
      return _buildShimmerPreview(context);
    }

    if (isPdf) {
      return _buildPdfPreview(context);
    }

    if (isImage) {
      return _buildImagePreview(context);
    }

    return _buildUnknownPreview(context);
  }

  Widget _buildShimmerPreview(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFFE0E0E0),
          highlightColor: const Color(0xFFF5F5F5),
          child: Container(
            height: 180,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPreview(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4F0),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            DocumentConstants.previewNotAvailable,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnknownPreview(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4F0),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            widget.document.fileType?.toUpperCase() ?? 'FILE',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfPreview(BuildContext context) {
    final url = _downloadUrl!;
    return GestureDetector(
      onTap: () => _openFullScreenPdf(context, url),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F4F0),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IgnorePointer(
            child: SfPdfViewer.network(
              url,
              canShowScrollHead: false,
              canShowScrollStatus: false,
              enableDoubleTapZooming: false,
              pageSpacing: 0,
              initialZoomLevel: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  void _openFullScreenPdf(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(widget.document.label),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          backgroundColor: Colors.black,
          body: SfPdfViewer.network(url),
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    final url = _downloadUrl!;
    final docId = widget.document.id;
    return GestureDetector(
      onTap: () => _openFullScreenImage(context, url, docId),
      child: Hero(
        tag: 'document_preview_$docId',
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F4F0),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: const Color(0xFFE0E0E0),
                highlightColor: const Color(0xFFF5F5F5),
                child: Container(height: 180, color: Colors.white),
              ),
              errorWidget: (context, url, error) => _buildErrorPreview(context),
            ),
          ),
        ),
      ),
    );
  }

  void _openFullScreenImage(BuildContext context, String url, String docId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(widget.document.label),
          ),
          body: Hero(
            tag: 'document_preview_$docId',
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  final DocumentEntity document;
  final String orderRef;

  const _MetadataCard({required this.document, required this.orderRef});

  @override
  Widget build(BuildContext context) {
    final docTypeLabel = DocumentConstants.docTypeLabels[document.docType] ?? document.docType;
    final uploadedByLabel = document.uploadedByRole == 'buyer'
        ? DocumentConstants.you
        : document.uploadedByRole == 'agent'
            ? DocumentConstants.agent
            : DocumentConstants.system;
    final uploadDateStr = document.uploadedAt != null
        ? DateFormat('d MMM yyyy').format(document.uploadedAt!)
        : DocumentConstants.notApplicable;
    final verifiedStr = document.isVerified
        ? DocumentConstants.platformAutoCheck
        : DocumentConstants.notApplicable;
    final verifiedDateStr = document.verifiedAt != null
        ? DateFormat('d MMM yyyy').format(document.verifiedAt!)
        : DocumentConstants.notApplicable;
    final fileTypeStr = (document.fileType ?? '—').toUpperCase();
    final fileSizeStr = document.fileSizeKb != null
        ? (document.fileSizeKb! >= 1024
            ? '${(document.fileSizeKb! / 1024).toStringAsFixed(1)} MB'
            : '${document.fileSizeKb} KB')
        : DocumentConstants.notApplicable;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _MetaRow(DocumentConstants.documentType, docTypeLabel),
          _MetaRow(DocumentConstants.order, orderRef),
          _MetaRow(DocumentConstants.vehicleVin, document.vin ?? DocumentConstants.notApplicable),
          _MetaRow(DocumentConstants.uploadedBy, uploadedByLabel),
          _MetaRow(DocumentConstants.uploadDate, uploadDateStr),
          _MetaRow(DocumentConstants.verifiedBy, verifiedStr),
          _MetaRow(DocumentConstants.verifiedDate, verifiedDateStr),
          _MetaRow(DocumentConstants.fileType, fileTypeStr),
          _MetaRow(DocumentConstants.fileSize, fileSizeStr),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectionReasonCard extends StatelessWidget {
  final String? reason;
  final String orderId;

  const _RejectionReasonCard({this.reason, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEBEB),
        border: Border(
          left: BorderSide(color: const Color(0xFFE24B4A), width: 3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DocumentConstants.rejectionReason.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFA32D2D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reason ?? DocumentConstants.notApplicable,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFFA32D2D),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/order/$orderId?tab=chat'),
            child: Text(
              DocumentConstants.contactAgentForHelp,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool inProgress;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.inProgress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: onTap == null ? Colors.grey.shade300 : AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: inProgress ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: inProgress
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _DocumentDetailLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: const Color(0xFFE0DFD8)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Shimmer.fromColors(
            baseColor: const Color(0xFFE0E0E0),
            highlightColor: const Color(0xFFF5F5F5),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: const Color(0xFFE0E0E0),
            highlightColor: const Color(0xFFF5F5F5),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
