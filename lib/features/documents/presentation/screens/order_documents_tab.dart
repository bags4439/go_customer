import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../core/constants/document_constants.dart';
import '../../domain/entities/document_entity.dart';
import '../models/document_list_item.dart';
import '../models/document_progress.dart';
import '../providers/documents_providers.dart';
import '../widgets/dashed_border_painter.dart';
import 'rejected_document_bottom_sheet.dart';

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
    final docsAsync = ref.watch(orderDocumentsProvider(widget.orderId));
    final progress = ref.watch(documentProgressProvider(widget.orderId));

    return docsAsync.when(
      data: (docs) {
        final sections = ref.watch(documentsBySectionProvider(widget.orderId));
        final hasAnySection = sections.isNotEmpty;
        final totalItems = sections.values.fold<int>(0, (s, list) => s + list.length);

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
              orderId: widget.orderId,
              progress: progress,
              animatedProgress: _animatedProgress,
              displayedCount: _displayedCount,
              onProgressAnimated: (v) => setState(() => _animatedProgress = v),
              onAnimationEnd: (count) => setState(() => _displayedCount = count),
            ),
            const SizedBox(height: 16),
            ...sections.entries.expand((entry) {
              final sectionKey = entry.key;
              final items = entry.value;
              final sectionLabel = _sectionLabel(sectionKey);
              return [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 6),
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
                  final isNew = item is RealDocumentItem && newIds.contains(item.document.id);
                  return _DocumentListItemWidget(
                    orderId: widget.orderId,
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
  final String orderId;
  final DocumentProgress progress;
  final double animatedProgress;
  final int displayedCount;
  final ValueChanged<double> onProgressAnimated;
  final ValueChanged<int>? onAnimationEnd;

  const _ProgressSection({
    required this.orderId,
    required this.progress,
    required this.animatedProgress,
    required this.displayedCount,
    required this.onProgressAnimated,
    this.onAnimationEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = progress.readyCount >= 7;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animatedProgress, end: progress.fraction),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      onEnd: () {
        onProgressAnimated(progress.fraction);
        onAnimationEnd?.call(progress.readyCount);
      },
      builder: (context, value, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F4F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DocumentConstants.progressTitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '$displayedCount ${DocumentConstants.progressOf}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 5,
                  child: Stack(
                    children: [
                      Container(color: const Color(0xFFE0DFD8)),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth * value.clamp(0.0, 1.0);
                          return SizedBox(
                            width: w,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: isComplete ? const Color(0xFF1D9E75) : AppColors.secondary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                displayedCount >= 7
                    ? DocumentConstants.progressAllReady
                    : '${7 - displayedCount} ${DocumentConstants.progressSubNote}',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: displayedCount >= 7
                      ? const Color(0xFF1D9E75)
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
          fontWeight: FontWeight.w500,
          color: const Color(0xFFAAAAAA),
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
              fontWeight: FontWeight.w500,
              color: const Color(0xFFAAAAAA),
            ),
          ),
        );
      },
    );
  }
}

class _DocumentListItemWidget extends StatelessWidget {
  final String orderId;
  final DocumentListItem item;
  final int entranceIndex;
  final AnimationController? entranceController;
  final int totalItemCount;
  final bool isNewFromStream;
  final VoidCallback onTap;

  const _DocumentListItemWidget({
    required this.orderId,
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
      return _PlaceholderItem(item: item as PlaceholderDocumentItem);
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
        padding: const EdgeInsets.only(bottom: 7),
        child: _NewDocumentSlideIn(child: realContent),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
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
    Widget content = _RealDocumentContent(
      document: document,
      onTap: onTap,
    );
    if (entranceController != null && totalItemCount > 0) {
      content = AnimatedBuilder(
        animation: entranceController!,
        builder: (context, _) {
          final totalDuration = totalItemCount * 40 + 260;
          final start = (entranceIndex * 40) / 1000.0 / (totalDuration / 1000.0);
          final end = (entranceIndex * 40 + 200) / 1000.0 / (totalDuration / 1000.0);
          final t = ((entranceController!.value - start) / (end - start)).clamp(0.0, 1.0);
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
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
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
          child: SlideTransition(
            position: _slide,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _RealDocumentContent extends StatelessWidget {
  final DocumentEntity document;
  final VoidCallback onTap;

  const _RealDocumentContent({
    required this.document,
    required this.onTap,
  });

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
    final statusLabel = document.status == 'verified'
        ? DocumentConstants.statusVerified
        : document.status == 'pending'
            ? DocumentConstants.statusPending
            : DocumentConstants.statusRejected;
    final statusBg = document.status == 'verified'
        ? const Color(0xFFEAF3DE)
        : document.status == 'pending'
            ? const Color(0xFFFAEEDA)
            : const Color(0xFFFCEBEB);
    final statusFg = document.status == 'verified'
        ? const Color(0xFF27500A)
        : document.status == 'pending'
            ? const Color(0xFF633806)
            : const Color(0xFFA32D2D);

    return Container(
      decoration: BoxDecoration(
        border: isRejected
            ? const Border(left: BorderSide(color: Color(0xFFE24B4A), width: 3))
            : null,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: const Color(0xFFE6F1FB),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$uploaderText · $dateStr',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isRejected)
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  )
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 4),
                Container(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderItem extends StatelessWidget {
  final PlaceholderDocumentItem item;

  const _PlaceholderItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final label = DocumentConstants.docTypeLabels[item.docType] ?? item.docType;
    final subText = item.isGhanaId
        ? DocumentConstants.uploadRequired
        : item.availableAfterLabel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Opacity(
        opacity: 0.75,
        child: CustomPaint(
          painter: DashedBorderPainter(borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F8F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F4F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _docTypeAbbrev(item.docType),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subText,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      if (item.isGhanaId) ...[
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => context.push('/profile/id-verification'),
                          child: Text(DocumentConstants.uploadNow),
                        ),
                      ],
                    ],
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

String _docTypeAbbrev(String docType) {
  const m = {
    'ghana_id': 'ID',
    'vehicle_title': 'TIT',
    'bill_of_lading': 'BOL',
    'commercial_invoice': 'INV',
    'packing_list': 'PKL',
    'payment_receipt': 'REC',
    'gra_declaration': 'GRA',
    'duty_receipt': 'DUT',
    'insurance_certificate': 'INS',
    'repair_quote': 'QUO',
    'repair_receipt': 'REP',
    'delivery_note': 'DEL',
    'other': 'DOC',
  };
  return m[docType] ?? 'DOC';
}

class _DocTypeIcon extends StatelessWidget {
  final String docType;

  const _DocTypeIcon({required this.docType});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(docType);
    final abbrev = _docTypeAbbrev(docType);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        abbrev,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  (Color, Color) _colors(String docType) {
    switch (docType) {
      case 'ghana_id':
        return (const Color(0xFFE6F1FB), const Color(0xFF185FA5));
      case 'vehicle_title':
      case 'payment_receipt':
        return (const Color(0xFFEAF3DE), const Color(0xFF27500A));
      case 'bill_of_lading':
      case 'commercial_invoice':
      case 'packing_list':
      case 'repair_quote':
      case 'repair_receipt':
        return (const Color(0xFFFAEEDA), const Color(0xFF633806));
      case 'gra_declaration':
      case 'duty_receipt':
        return (const Color(0xFFFCEBEB), const Color(0xFFA32D2D));
      case 'insurance_certificate':
        return (const Color(0xFFEEEDFE), const Color(0xFF3C3489));
      case 'delivery_note':
        return (const Color(0xFFE1F5EE), const Color(0xFF085041));
      default:
        return (const Color(0xFFF5F4F0), const Color(0xFFAAAAAA));
    }
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
            Icon(
              Icons.folder_open,
              size: 48,
              color: const Color(0xFFE0DFD8),
            ),
            const SizedBox(height: 16),
            Text(
              DocumentConstants.noDocumentsYet,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DocumentConstants.noDocumentsBody,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFE24B4A)),
            const SizedBox(height: 16),
            Text(
              DocumentConstants.errorLoadDocuments,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(DocumentConstants.retry),
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
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.only(bottom: 7),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE0E0E0),
        highlightColor: const Color(0xFFF5F5F5),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 11,
                    width: 120,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
