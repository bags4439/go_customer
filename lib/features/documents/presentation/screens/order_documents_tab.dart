import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../orders/presentation/models/web_order_panel_task.dart';
import '../../../orders/presentation/providers/order_detail_providers.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_navigation.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../core/constants/document_constants.dart';
import '../../domain/entities/document_entity.dart';
import '../providers/documents_providers.dart';

/// Order detail tab: buyer ID document row + agent-uploaded documents (read-only).
class OrderDocumentsTab extends ConsumerWidget {
  const OrderDocumentsTab({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(orderDocumentsProvider(orderId));
    final profileAsync = ref.watch(currentUserProfileProvider);
    final user = profileAsync.valueOrNull;

    return docsAsync.when(
      data: (docs) => _DocumentsBody(
        orderId: orderId,
        docs: docs,
        user: user,
      ),
      loading: () => const _DocumentsShimmer(),
      error: (_, __) => _ErrorState(
        onRetry: () => ref.invalidate(orderDocumentsProvider(orderId)),
      ),
    );
  }
}

class _DocumentsBody extends StatelessWidget {
  const _DocumentsBody({
    required this.orderId,
    required this.docs,
    required this.user,
  });

  final String orderId;
  final List<DocumentEntity> docs;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final agentDocs = docs
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

    final hasIdDocument = user?.hasIdDocument ?? false;
    final hasAnything = hasIdDocument || agentDocs.isNotEmpty;

    if (!hasAnything) {
      return const _EmptyState();
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(
              title: DocumentConstants.sectionYourDocuments,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverToBoxAdapter(
            child: _IdDocumentRow(user: user),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(
              title: DocumentConstants.sectionFromAgent,
            ),
          ),
        ),
        if (agentDocs.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: const SliverToBoxAdapter(
              child: _NoAgentDocuments(),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: EdgeInsets.only(
                    bottom: i == agentDocs.length - 1 ? 0 : 8,
                  ),
                  child: _AgentDocumentTile(
                    orderId: orderId,
                    doc: agentDocs[i],
                  ),
                ),
                childCount: agentDocs.length,
              ),
            ),
          ),
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 40),
          sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.sectionLabel,
    );
  }
}

class _IdDocumentRow extends StatelessWidget {
  const _IdDocumentRow({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final hasId = user?.hasIdDocument ?? false;
    final docLabel = user?.idDocumentLabel ?? 'Identity document';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pushNamed(RouteConstants.idVerification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasId
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.borderSolid,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasId
                      ? AppColors.successMutedBackground
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  size: 20,
                  color: hasId ? AppColors.success : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasId
                          ? DocumentConstants.idDocProvided(docLabel)
                          : DocumentConstants.idDocMissing(docLabel),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasId
                          ? DocumentConstants.idDocProvidedSub()
                          : DocumentConstants.idDocMissingSub(docLabel),
                      style: AppTextStyles.cardLabel.copyWith(
                        color: hasId
                            ? AppColors.textSecondary
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoAgentDocuments extends StatelessWidget {
  const _NoAgentDocuments();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderSolid,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.folder_open_outlined,
            size: 28,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            DocumentConstants.noAgentDocuments,
            style: AppTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            DocumentConstants.noAgentDocumentsBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.textTertiary, height: 1.5, fontWeight: FontWeight.w400, letterSpacing: 0.0),
          ),
        ],
      ),
    );
  }
}

class _AgentDocumentTile extends ConsumerWidget {
  const _AgentDocumentTile({
    required this.orderId,
    required this.doc,
  });

  final String orderId;
  final DocumentEntity doc;

  bool get _isPdf =>
      (doc.fileType ?? '').toLowerCase().contains('pdf');

  bool get _isImage {
    final t = (doc.fileType ?? '').toLowerCase();
    return t.contains('image') ||
        t.contains('jpg') ||
        t.contains('jpeg') ||
        t.contains('png');
  }

  String get _typeLabel =>
      DocumentConstants.docTypeLabels[doc.docType] ?? doc.docType;

  String get _primaryTitle {
    final l = doc.label.trim();
    return l.isNotEmpty ? l : _typeLabel;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verified = doc.status == 'verified';
    final rejected = doc.status == 'rejected';
    final task = ref.watch(webOrderPanelTaskProvider);
    final isSelected = task is WebOrderPanelDocument &&
        task.documentId == doc.id &&
        task.orderId == orderId;

    final hasAccent = verified || rejected;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDocument(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              if (hasAccent)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    color: verified ? AppColors.success : AppColors.danger,
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(left: hasAccent ? 3 : 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.borderSolid,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _isPdf
                                ? AppColors.infoBackground
                                : _isImage
                                    ? AppColors.selectionTint
                                    : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _isPdf
                                ? Icons.picture_as_pdf_outlined
                                : _isImage
                                    ? Icons.image_outlined
                                    : Icons.insert_drive_file_outlined,
                            size: 20,
                            color: _isPdf
                                ? AppColors.infoText
                                : _isImage
                                    ? AppColors.secondary
                                    : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _primaryTitle,
                                style: AppTextStyles.labelLarge,
                              ),
                              if (doc.label.trim().isNotEmpty &&
                                  _typeLabel != _primaryTitle) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _typeLabel,
                                  style: AppTextStyles.cardLabel,
                                ),
                              ],
                              if (doc.notes != null &&
                                  doc.notes!.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  doc.notes!.trim(),
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                              if (doc.uploadedAt != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat('d MMM yyyy')
                                      .format(doc.uploadedAt!),
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.textTertiary, fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                        _StatusBadge(status: doc.status),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDocument(BuildContext context, WidgetRef ref) {
    if (doc.id.isEmpty) return;
    OrderDetailWebNavigation.openDocument(
      context,
      ref,
      orderId: orderId,
      documentId: doc.id,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (String label, Color bg, Color fg) = switch (status) {
      'verified' => (
          DocumentConstants.statusVerified,
          AppColors.successMutedBackground,
          AppColors.success,
        ),
      'rejected' => (
          DocumentConstants.statusRejected,
          AppColors.dangerMutedBackground,
          AppColors.danger,
        ),
      _ => (
          DocumentConstants.statusBadgePending,
          AppColors.amberBackground,
          AppColors.warning,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.badgeText
            .copyWith(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_outlined,
                size: 36,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DocumentConstants.noDocumentsYet,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              DocumentConstants.noDocumentsBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DocumentConstants.errorLoadDocuments,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(
              DocumentConstants.retry,
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.secondary, fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsShimmer extends StatelessWidget {
  const _DocumentsShimmer();

  static const Color _base = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Shimmer.fromColors(
          baseColor: _base,
          highlightColor: _highlight,
          child: Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: _base,
          highlightColor: _highlight,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSolid, width: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Shimmer.fromColors(
          baseColor: _base,
          highlightColor: _highlight,
          child: Container(
            height: 12,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Shimmer.fromColors(
              baseColor: _base,
              highlightColor: _highlight,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSolid, width: 0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
