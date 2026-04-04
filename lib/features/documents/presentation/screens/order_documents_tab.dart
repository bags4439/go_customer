import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../orders/presentation/providers/order_providers.dart';
import '../../core/constants/document_constants.dart';
import '../../domain/entities/document_entity.dart';
import '../models/document_list_item.dart';
import '../models/document_progress.dart';
import '../providers/documents_providers.dart';
import 'rejected_document_bottom_sheet.dart';

const Color _kPrimary = Color(0xFF378ADD);
const Color _kSuccess = Color(0xFF1D9E75);
const Color _kDanger = Color(0xFFE24B4A);
const Color _kWarning = Color(0xFFBA7517);
const Color _kSurface = Color(0xFFF5F4F0);
const Color _kBorder = Color(0xFFE0DFD8);
const Color _kTextPrimary = Color(0xFF1A1A18);
const Color _kTextSecondary = Color(0xFF666666);
const Color _kTextTertiary = Color(0xFFAAAAAA);
const Color _kSuccessBg = Color(0xFFEAF3DE);
const Color _kSuccessText = Color(0xFF27500A);
const Color _kAmberBg = Color(0xFFFAEEDA);
const Color _kAmberText = Color(0xFF633806);
const Color _kInfoBg = Color(0xFFEBF4FD);
const Color _kInfoText = Color(0xFF185FA5);

class OrderDocumentsTab extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDocumentsTab({super.key, required this.orderId});

  @override
  ConsumerState<OrderDocumentsTab> createState() => _OrderDocumentsTabState();
}

class _OrderDocumentsTabState extends ConsumerState<OrderDocumentsTab>
    with TickerProviderStateMixin {
  double _animatedProgress = 0;
  int _displayedCount = 0;
  bool _displayedCountInitialized = false;
  AnimationController? _entranceController;
  int _entranceItemCount = 0;
  Set<String> _seenDocumentIds = {};

  @override
  void dispose() {
    _entranceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(orderProvider(widget.orderId));
    final docsAsync = ref.watch(orderDocumentsProvider(widget.orderId));
    final progress = ref.watch(documentProgressProvider(widget.orderId));

    return docsAsync.when(
      data: (docs) {
        final sections = ref.watch(documentsBySectionProvider(widget.orderId));
        final hasAnySection = sections.isNotEmpty;
        final totalItems = sections.values.fold<int>(
          0,
          (s, list) => s + list.length,
        );

        if (!hasAnySection && docs.isEmpty) {
          return _EmptyState();
        }

        if (totalItems > 0 && _entranceController == null) {
          _entranceItemCount = totalItems;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _entranceController = AnimationController(
                vsync: this,
                duration: Duration(milliseconds: _entranceItemCount * 40 + 260),
              );
              _entranceController!.forward();
            });
          });
        }

        if (!_displayedCountInitialized) {
          _displayedCountInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _displayedCount = progress.readyCount);
          });
        }

        final currentRealIds = <String>{
          for (final list in sections.values)
            for (final item in list)
              if (item is RealDocumentItem) item.document.id,
        };
        final newIds = _seenDocumentIds.isEmpty
            ? <String>{}
            : currentRealIds.difference(_seenDocumentIds);
        if (_seenDocumentIds.isEmpty) {
          _seenDocumentIds = Set.from(currentRealIds);
        } else {
          _seenDocumentIds = _seenDocumentIds.union(currentRealIds);
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            _ProgressSection(
              progress: progress,
              animatedProgress: _animatedProgress,
              displayedCount: _displayedCount,
              onProgressAnimated: (v) => setState(() => _animatedProgress = v),
              onAnimationEnd: (count) =>
                  setState(() => _displayedCount = count),
            ),
            const SizedBox(height: 16),
            ...sections.entries.expand((entry) {
              final sectionKey = entry.key;
              final items = entry.value;
              final sectionLabel = _sectionLabel(sectionKey);
              return [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 8),
                  child: _AnimatedSectionHeader(
                    label: sectionLabel,
                    delayMs: _entranceController != null ? 60 : 0,
                    controller: _entranceController,
                    totalItemCount: totalItems,
                  ),
                ),
                ...items.asMap().entries.map((itemEntry) {
                  final index = itemEntry.key;
                  final item = itemEntry.value;
                  final isNew =
                      item is RealDocumentItem &&
                      newIds.contains(item.document.id);
                  return _DocumentListItemWidget(
                    item: item,
                    entranceIndex: index,
                    entranceController: _entranceController,
                    totalItemCount: totalItems,
                    isNewFromStream: isNew,
                    onTap: () => _onItemTap(context, item),
                  );
                }),
              ];
            }),
          ],
        );
      },
      loading: () => const _ShimmerDocuments(),
      error: (e, _) => _ErrorState(
        onRetry: () => ref.invalidate(orderDocumentsProvider(widget.orderId)),
      ),
    );
  }

  String _sectionLabel(String key) {
    switch (key) {
      case 'yourDocuments':
        return DocumentConstants.sectionYourDocuments;
      case 'vehicleAndPurchase':
        return DocumentConstants.sectionVehicleAndPurchase;
      case 'customsAndClearance':
        return DocumentConstants.sectionCustomsAndClearance;
      case 'repairs':
        return DocumentConstants.sectionRepairs;
      case 'delivery':
        return DocumentConstants.sectionDelivery;
      default:
        return key;
    }
  }

  void _onItemTap(BuildContext context, DocumentListItem item) {
    if (item is PlaceholderDocumentItem) {
      if (item.isGhanaId) {
        context.push('/profile/id-verification');
      }
      return;
    }
    final real = item as RealDocumentItem;
    if (real.document.isRejected) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => RejectedDocumentBottomSheet(
          document: real.document,
          orderId: widget.orderId,
        ),
      );
      return;
    }
    context.push('/order/${widget.orderId}/documents/${real.document.id}');
  }
}

class _ProgressSection extends StatelessWidget {
  final DocumentProgress progress;
  final double animatedProgress;
  final int displayedCount;
  final ValueChanged<double> onProgressAnimated;
  final ValueChanged<int>? onAnimationEnd;

  const _ProgressSection({
    required this.progress,
    required this.animatedProgress,
    required this.displayedCount,
    required this.onProgressAnimated,
    this.onAnimationEnd,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animatedProgress, end: progress.fraction),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      onEnd: () {
        onProgressAnimated(progress.fraction);
        onAnimationEnd?.call(progress.readyCount);
      },
      builder: (context, value, _) {
        final v = value.clamp(0.0, 1.0);
        final allReady = displayedCount >= progress.totalExpected;
        final pillComplete = v >= 1.0 - 1e-6 || progress.fraction >= 1.0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DocumentConstants.documentsProgressHeading,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${progress.readyCount} of ${progress.totalExpected} ${DocumentConstants.documentsProgressReadySuffix}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: _kTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pillComplete ? _kSuccessBg : _kInfoBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pillComplete
                          ? DocumentConstants.progressPillComplete
                          : '${(v * 100).round()}%',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: pillComplete ? _kSuccessText : _kInfoText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  backgroundColor: _kBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pillComplete ? _kSuccess : _kPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                allReady
                    ? DocumentConstants.progressAllReady
                    : '${(progress.totalExpected - displayedCount).clamp(0, progress.totalExpected)} ${DocumentConstants.progressSubNote}',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: allReady ? _kSuccess : _kTextTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedSectionHeader extends StatelessWidget {
  final String label;
  final int delayMs;
  final AnimationController? controller;
  final int totalItemCount;

  const _AnimatedSectionHeader({
    required this.label,
    this.delayMs = 0,
    this.controller,
    this.totalItemCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (controller == null || totalItemCount == 0) {
      return Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: _kTextTertiary,
        ),
      );
    }
    return AnimatedBuilder(
      animation: controller!,
      builder: (context, _) {
        final totalDuration = totalItemCount * 40 + 260;
        final headerStart = (delayMs / 1000.0) / (totalDuration / 1000.0);
        final t = ((controller!.value - headerStart) / 0.15).clamp(0.0, 1.0);
        final opacity = Curves.easeOut.transform(t);
        return Opacity(
          opacity: opacity,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: _kTextTertiary,
            ),
          ),
        );
      },
    );
  }
}

class _DocumentListItemWidget extends StatelessWidget {
  final DocumentListItem item;
  final int entranceIndex;
  final AnimationController? entranceController;
  final int totalItemCount;
  final bool isNewFromStream;
  final VoidCallback onTap;

  const _DocumentListItemWidget({
    required this.item,
    required this.entranceIndex,
    required this.entranceController,
    required this.totalItemCount,
    required this.isNewFromStream,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (item is PlaceholderDocumentItem) {
      return _PlaceholderItem(
        item: item as PlaceholderDocumentItem,
        onTap: onTap,
      );
    }
    final realContent = _RealDocumentItemWidget(
      document: (item as RealDocumentItem).document,
      entranceIndex: entranceIndex,
      entranceController: entranceController,
      totalItemCount: totalItemCount,
      onTap: onTap,
    );
    if (isNewFromStream) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _NewDocumentSlideIn(child: realContent),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: realContent,
    );
  }
}

class _RealDocumentItemWidget extends StatelessWidget {
  final DocumentEntity document;
  final int entranceIndex;
  final AnimationController? entranceController;
  final int totalItemCount;
  final VoidCallback onTap;

  const _RealDocumentItemWidget({
    required this.document,
    required this.entranceIndex,
    required this.entranceController,
    required this.totalItemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = _RealDocumentContent(document: document, onTap: onTap);
    if (entranceController != null && totalItemCount > 0) {
      content = AnimatedBuilder(
        animation: entranceController!,
        builder: (context, _) {
          final totalDuration = totalItemCount * 40 + 260;
          final start =
              (entranceIndex * 40) / 1000.0 / (totalDuration / 1000.0);
          final end =
              (entranceIndex * 40 + 200) / 1000.0 / (totalDuration / 1000.0);
          final t = ((entranceController!.value - start) / (end - start)).clamp(
            0.0,
            1.0,
          );
          final curved = Curves.easeOut.transform(t);
          return Opacity(
            opacity: curved,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - curved)),
              child: content,
            ),
          );
        },
      );
    }
    return content;
  }
}

class _NewDocumentSlideIn extends StatefulWidget {
  final Widget child;

  const _NewDocumentSlideIn({required this.child});

  @override
  State<_NewDocumentSlideIn> createState() => _NewDocumentSlideInState();
}

class _NewDocumentSlideInState extends State<_NewDocumentSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return FadeTransition(
          opacity: _opacity,
          child: SlideTransition(position: _slide, child: widget.child),
        );
      },
    );
  }
}

class _RealDocumentContent extends StatelessWidget {
  final DocumentEntity document;
  final VoidCallback onTap;

  const _RealDocumentContent({required this.document, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRejected = document.isRejected;
    final uploaderText = document.uploadedByRole == 'buyer'
        ? DocumentConstants.uploadedByYou
        : document.uploadedByRole == 'agent'
        ? DocumentConstants.uploadedByAgent
        : DocumentConstants.addedAutomatically;
    final dateStr = document.uploadedAt != null
        ? DateFormat('d MMM yyyy').format(document.uploadedAt!)
        : '';

    return Container(
      decoration: BoxDecoration(
        border: isRejected
            ? const Border(left: BorderSide(color: _kDanger, width: 3))
            : Border.all(color: _kBorder, width: 0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFFE6F1FB),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _DocTypeIcon(docType: document.docType),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _kTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$uploaderText · $dateStr',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _kTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isRejected) ...[
                  _DocStatusBadge(status: document.status),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: _kTextTertiary),
                ] else ...[
                  _DocStatusBadge(status: document.status),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocStatusBadge extends StatelessWidget {
  final String status;

  const _DocStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (String label, Color bg, Color text) = switch (status) {
      'verified' => (
        DocumentConstants.statusVerified,
        _kSuccessBg,
        _kSuccessText,
      ),
      'pending' => (DocumentConstants.statusBadgePending, _kInfoBg, _kInfoText),
      'rejected' => (
        DocumentConstants.statusRejected,
        const Color(0xFFFCEBEB),
        _kDanger,
      ),
      _ => (DocumentConstants.statusBadgeNotStarted, _kSurface, _kTextTertiary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }
}

class _DocTypeIcon extends StatelessWidget {
  final String docType;
  final bool isProvided;

  const _DocTypeIcon({required this.docType, this.isProvided = false});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (docType) {
      'ghana_id' => (Icons.badge_outlined, isProvided ? _kSuccess : _kWarning),
      'vehicle_title' => (Icons.directions_car_outlined, _kPrimary),
      'payment_receipt' => (Icons.receipt_outlined, _kSuccess),
      'bill_of_lading' => (Icons.directions_boat_outlined, _kPrimary),
      'commercial_invoice' => (Icons.description_outlined, _kPrimary),
      'packing_list' => (Icons.list_alt_outlined, _kTextSecondary),
      'gra_declaration' => (Icons.account_balance_outlined, _kPrimary),
      'duty_receipt' => (Icons.receipt_long_outlined, _kSuccess),
      'insurance_certificate' => (Icons.security_outlined, _kPrimary),
      'repair_quote' => (Icons.build_outlined, _kWarning),
      'repair_receipt' => (Icons.build_circle_outlined, _kSuccess),
      'delivery_note' => (Icons.local_shipping_outlined, _kSuccess),
      _ => (Icons.insert_drive_file_outlined, _kTextTertiary),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

Widget _documentsTabPlaceholderChrome({
  required VoidCallback onTap,
  required Widget child,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _kBorder, width: 0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFFE6F1FB),
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    ),
  );
}

class _PlaceholderItem extends StatelessWidget {
  final PlaceholderDocumentItem item;
  final VoidCallback onTap;

  const _PlaceholderItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (item.isGhanaId && item.isGhanaIdProvided) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _documentsTabPlaceholderChrome(
          onTap: onTap,
          child: Row(
            children: [
              _DocTypeIcon(docType: 'ghana_id', isProvided: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DocumentConstants.ghanaCardProvided,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DocumentConstants.ghanaCardProvidedSub,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: _kTextTertiary),
            ],
          ),
        ),
      );
    }

    if (item.isGhanaId && !item.isGhanaIdProvided) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _documentsTabPlaceholderChrome(
          onTap: onTap,
          child: Row(
            children: [
              _DocTypeIcon(docType: 'ghana_id', isProvided: false),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DocumentConstants.ghanaCardMissing,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DocumentConstants.ghanaCardMissingSub,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _kWarning,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _kAmberBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DocumentConstants.addNow,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _kAmberText,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final label = DocumentConstants.docTypeLabels[item.docType] ?? item.docType;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _documentsTabPlaceholderChrome(
        onTap: onTap,
        child: Row(
          children: [
            _DocTypeIcon(docType: item.docType),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _kTextTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.availableAfterLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _kTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.lock_outline, size: 16, color: _kBorder),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.folder_open_outlined,
                size: 40,
                color: _kTextTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DocumentConstants.noDocumentsYet,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DocumentConstants.noDocumentsBody,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: _kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.wifi_off_outlined,
                size: 32,
                color: _kTextTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DocumentConstants.couldNotLoadDocumentsTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                DocumentConstants.retry,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _kPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerDocuments extends StatelessWidget {
  const _ShimmerDocuments();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      children: [
        Shimmer.fromColors(
          baseColor: const Color(0xFFE0E0E0),
          highlightColor: const Color(0xFFF5F5F5),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder, width: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(3, (_) => const _ShimmerItem()),
      ],
    );
  }
}

class _ShimmerItem extends StatelessWidget {
  const _ShimmerItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE0E0E0),
        highlightColor: const Color(0xFFF5F5F5),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 120, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
