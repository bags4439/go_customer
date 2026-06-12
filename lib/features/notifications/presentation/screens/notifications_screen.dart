import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/widgets/dashboard_mobile_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/styled_snackbar.dart';
import '../../../../core/widgets/web_dashboard_right_panel.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../guide/core/constants/guide_keys.dart';
import '../../../guide/presentation/widgets/guide_contextual_hint_banner.dart';
import '../../../guide/presentation/widgets/guide_help_button.dart';
import '../../core/constants/notification_constants.dart';
import '../../core/utils/notification_action_label.dart';
import '../../core/utils/notification_timestamp.dart';
import '../navigation/notification_navigation.dart';
import '../widgets/notification_type_icon.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_list_item.dart';
import '../providers/notifications_providers.dart';

double _notificationsShellFloatingNavExtra(BuildContext context) {
  if (!AppBreakpoints.useMobileShell(context)) return 0;
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  return bottomInset + 64 + 24;
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  Future<void> _onMarkAllRead(BuildContext context, WidgetRef ref) async {
    final filter = ref.read(notificationFilterProvider);
    final items = ref.read(notificationListItemsProvider(filter));
    final unreadIds = [
      for (final item in items)
        if (item is NotificationListItemEntry && !item.notification.isRead)
          item.notification.id,
    ];
    if (unreadIds.isEmpty) return;
    ref.read(markAllReadIdsProvider.notifier).state = unreadIds;
    ref.read(markAllReadInProgressProvider.notifier).state = true;
    try {
      await ref
          .read(notificationsNotifierProvider.notifier)
          .markAllRead(unreadIds);
    } catch (_) {
      ref.read(markAllReadIdsProvider.notifier).state = null;
      if (context.mounted) {
        showErrorSnackBar(
          context,
          NotificationConstants.markAllReadError,
          actionLabel: NotificationConstants.retry,
          onAction: () => _onMarkAllRead(context, ref),
        );
      }
    } finally {
      ref.read(markAllReadInProgressProvider.notifier).state = false;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int unreadCount) {
    final useMobileShell = AppBreakpoints.useMobileShell(context);

    if (useMobileShell) {
      final title = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            NotificationConstants.appBarTitle,
            style: AppTextStyles.appBarTitle.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unreadCount > 0
                ? '$unreadCount ${NotificationConstants.unreadSuffix}'
                : NotificationConstants.allCaughtUp,
            style: AppTextStyles.cardLabel.copyWith(
              color: unreadCount > 0
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75)
                  : AppColors.success,
            ),
          ),
        ],
      );
      final actions = <Widget>[
        const GuideHelpButton(),
        if (unreadCount > 0)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _MarkAllReadButton(onMarkAllRead: _onMarkAllRead),
          ),
      ];

      return AppBar(
        backgroundColor: dashboardMobileAppBarBackground(context),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: DashboardAppBarToolbar(leading: title, actions: actions),
        actions: const <Widget>[],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: AppColors.border, height: 0.5),
        ),
      );
    }

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Text(
        NotificationConstants.appBarTitle,
        style: AppTextStyles.appBarTitle.copyWith(color: AppColors.primary),
      ),
      actions: [
        const GuideHelpButton(),
        if (unreadCount > 0)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _MarkAllReadButton(onMarkAllRead: _onMarkAllRead),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.borderSolid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final isWeb = AppBreakpoints.useWebShell(context);
    const body = _NotificationsBody();

    if (isWeb) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: _buildAppBar(context, unreadCount),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: body),
            Container(width: 0.5, color: AppColors.borderSolid),
            const Expanded(flex: 4, child: WebDashboardRightPanel()),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context, unreadCount),
      body: const DashboardPortraitFrame(child: body),
    );
  }
}

class _MarkAllReadButton extends ConsumerWidget {
  final Future<void> Function(BuildContext context, WidgetRef ref)
  onMarkAllRead;

  const _MarkAllReadButton({required this.onMarkAllRead});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inProgress = ref.watch(markAllReadInProgressProvider);
    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: inProgress ? null : () => onMarkAllRead(context, ref),
        child: inProgress
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                NotificationConstants.markAllRead,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.secondary,
                  fontSize: 12,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

class _NotificationsBody extends ConsumerWidget {
  const _NotificationsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(notificationsNotifierProvider);
    final userId = ref.watch(authStateProvider).valueOrNull;
    // Watch filter so list [ValueKey] stays in sync and rebuilds with tabs.
    final filter = ref.watch(notificationFilterProvider);

    if (userId == null || userId.isEmpty) {
      return Center(child: Text(NotificationConstants.signInPrompt));
    }

    return asyncState.when(
      data: (state) {
        if (state.streamError != null) {
          return _NotificationsError(
            onRetry: () {
              ref.invalidate(notificationsNotifierProvider);
            },
          );
        }
        return Column(
          children: [
            Padding(
              padding: DashboardLayout.bodyScrollPadding(context, top: 12),
              child: const GuideHint(guideKey: GuideKeys.notifications),
            ),
            const _FilterTabs(),
            Expanded(
              child: _NotificationsAnimatedBody(
                child: _NotificationsList(key: ValueKey(filter)),
              ),
            ),
          ],
        );
      },
      loading: () => const _ShimmerList(),
      error: (e, _) => _NotificationsError(
        onRetry: () => ref.invalidate(notificationsNotifierProvider),
      ),
    );
  }
}

class _FilterTabs extends ConsumerWidget {
  const _FilterTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notificationFilterProvider);
    final hasUnreadAll = ref.watch(
      unreadCountByFilterProvider(NotificationFilter.all),
    );
    final hasUnreadPayments = ref.watch(
      unreadCountByFilterProvider(NotificationFilter.payments),
    );
    final hasUnreadOrderUpdates = ref.watch(
      unreadCountByFilterProvider(NotificationFilter.orderUpdates),
    );
    final hasUnreadMessages = ref.watch(
      unreadCountByFilterProvider(NotificationFilter.messages),
    );
    final hasUnreadAlerts = ref.watch(
      unreadCountByFilterProvider(NotificationFilter.alerts),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: DashboardLayout.bodyScrollPadding(context, top: 12, bottom: 12),
      child: Row(
        children: [
          _FilterPill(
            label: NotificationConstants.filterAll,
            isActive: filter == NotificationFilter.all,
            hasUnread: hasUnreadAll,
            onTap: () => ref.read(notificationFilterProvider.notifier).state =
                NotificationFilter.all,
          ),
          const SizedBox(width: 8),
          _FilterPill(
            label: NotificationConstants.filterPayments,
            isActive: filter == NotificationFilter.payments,
            hasUnread: hasUnreadPayments,
            onTap: () => ref.read(notificationFilterProvider.notifier).state =
                NotificationFilter.payments,
          ),
          const SizedBox(width: 8),
          _FilterPill(
            label: NotificationConstants.filterOrderUpdates,
            isActive: filter == NotificationFilter.orderUpdates,
            hasUnread: hasUnreadOrderUpdates,
            onTap: () => ref.read(notificationFilterProvider.notifier).state =
                NotificationFilter.orderUpdates,
          ),
          const SizedBox(width: 8),
          _FilterPill(
            label: NotificationConstants.filterMessages,
            isActive: filter == NotificationFilter.messages,
            hasUnread: hasUnreadMessages,
            onTap: () => ref.read(notificationFilterProvider.notifier).state =
                NotificationFilter.messages,
          ),
          const SizedBox(width: 8),
          _FilterPill(
            label: NotificationConstants.filterAlerts,
            isActive: filter == NotificationFilter.alerts,
            hasUnread: hasUnreadAlerts,
            onTap: () => ref.read(notificationFilterProvider.notifier).state =
                NotificationFilter.alerts,
          ),
        ],
      ),
    );
  }
}

/// Same motion as [home_screen.dart] `_AnimatedBody`: light fade + slide-in.
class _NotificationsAnimatedBody extends StatefulWidget {
  const _NotificationsAnimatedBody({required this.child});

  final Widget child;

  @override
  State<_NotificationsAnimatedBody> createState() =>
      _NotificationsAnimatedBodyState();
}

class _NotificationsAnimatedBodyState extends State<_NotificationsAnimatedBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) => _runEntrance());
  }

  void _runEntrance() {
    if (!mounted) return;
    if (TickerMode.of(context)) {
      _ctrl.forward();
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Same motion as [home_screen.dart] `_StaggeredItem`: staggered fade + slide.
class _NotificationsStaggeredRow extends StatefulWidget {
  const _NotificationsStaggeredRow({required this.index, required this.child});

  /// List row index (for delay); capped internally for long lists.
  final int index;
  final Widget child;

  @override
  State<_NotificationsStaggeredRow> createState() =>
      _NotificationsStaggeredRowState();
}

class _NotificationsStaggeredRowState extends State<_NotificationsStaggeredRow>
    with SingleTickerProviderStateMixin {
  static const int _kMaxStaggerIndex = 15;

  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    final capped = widget.index.clamp(0, _kMaxStaggerIndex);
    final delayMs = widget.index <= _kMaxStaggerIndex ? capped * 60 : 0;

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      if (TickerMode.of(context)) {
        _ctrl.forward();
      } else {
        _ctrl.value = 1.0;
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool hasUnread;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.hasUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: const Color(0xFFE6F1FB),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE6F1FB) : Colors.transparent,
            border: Border.all(
              color: isActive ? const Color(0xFFB5D4F4) : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: isActive
                      ? const Color(0xFF185FA5)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasUnread) ...[
                const SizedBox(width: 6),
                AnimatedScale(
                  scale: hasUnread ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsList extends ConsumerStatefulWidget {
  const _NotificationsList({super.key});

  @override
  ConsumerState<_NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends ConsumerState<_NotificationsList>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  AnimationController? _markAllReadController;
  List<String>? _markAllReadIds;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _markAllReadController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final userId = ref.read(authStateProvider).valueOrNull;
      if (userId != null) {
        ref.read(notificationsNotifierProvider.notifier).loadMore(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(notificationFilterProvider);
    final items = ref.watch(notificationListItemsProvider(filter));
    final markAllReadIds = ref.watch(markAllReadIdsProvider);
    final asyncState = ref.watch(notificationsNotifierProvider);
    final state = asyncState.valueOrNull;
    final hasMore = state?.hasMore ?? false;
    final isLoadingMore = state?.isLoadingMore ?? false;

    if (markAllReadIds != null &&
        markAllReadIds.isNotEmpty &&
        _markAllReadController == null) {
      _markAllReadIds = markAllReadIds;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _markAllReadController != null) return;
        _markAllReadController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: markAllReadIds.length * 30 + 200),
        );
        _markAllReadController!.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            ref.read(markAllReadIdsProvider.notifier).state = null;
            _markAllReadController?.dispose();
            _markAllReadController = null;
            _markAllReadIds = null;
            if (mounted) setState(() {});
          }
        });
        _markAllReadController!.forward();
        setState(() {});
      });
    }
    if (markAllReadIds == null || markAllReadIds.isEmpty) {
      if (_markAllReadController != null) {
        _markAllReadController!.dispose();
        _markAllReadController = null;
      }
      _markAllReadIds = null;
    }

    if (items.isEmpty) {
      return _EmptyState(filter: filter);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: DashboardLayout.bodyScrollPadding(
        context,
        top: 8,
        bottom: 8 + _notificationsShellFloatingNavExtra(context),
      ),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            );
          }
          if (hasMore) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 1, width: 40, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    NotificationConstants.noMoreNotifications,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Container(height: 1, width: 40, color: AppColors.border),
              ],
            ),
          );
        }

        final item = items[index];
        if (item is NotificationListItemSection) {
          return _NotificationsStaggeredRow(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 6),
              child: Text(item.label, style: AppTextStyles.sectionLabel),
            ),
          );
        }
        final entry = item as NotificationListItemEntry;
        final markAllReadStaggerIndex =
            _markAllReadIds?.indexOf(entry.notification.id) ?? -1;
        final markAllReadTotal = _markAllReadIds?.length ?? 0;
        Widget card = _NotificationItemCard(
          notification: entry.notification,
          onTap: () => _onNotificationTap(context, ref, entry.notification),
          onActionTap: () => _onActionTap(context, ref, entry.notification),
          markAllReadAnimation:
              _markAllReadController != null && markAllReadStaggerIndex >= 0
              ? _markAllReadController!
              : null,
          markAllReadStaggerIndex: markAllReadStaggerIndex >= 0
              ? markAllReadStaggerIndex
              : null,
          markAllReadTotalCount: markAllReadTotal > 0 ? markAllReadTotal : null,
        );
        return _NotificationsStaggeredRow(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: card,
          ),
        );
      },
    );
  }

  void _onNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity n,
  ) {
    ref.read(notificationsNotifierProvider.notifier).markRead(n.id);
    NotificationNavigation.open(context, ref, n);
  }

  void _onActionTap(BuildContext context, WidgetRef ref, NotificationEntity n) {
    ref.read(notificationsNotifierProvider.notifier).markRead(n.id);
    NotificationNavigation.open(context, ref, n);
  }
}

class _NotificationItemCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onActionTap;
  final Animation<double>? markAllReadAnimation;
  final int? markAllReadStaggerIndex;
  final int? markAllReadTotalCount;

  const _NotificationItemCard({
    required this.notification,
    required this.onTap,
    required this.onActionTap,
    this.markAllReadAnimation,
    this.markAllReadStaggerIndex,
    this.markAllReadTotalCount,
  });

  @override
  Widget build(BuildContext context) {
    final useMarkAllReadAnimation =
        markAllReadAnimation != null &&
        markAllReadStaggerIndex != null &&
        markAllReadTotalCount != null &&
        markAllReadTotalCount! > 0;
    if (useMarkAllReadAnimation) {
      return AnimatedBuilder(
        animation: markAllReadAnimation!,
        builder: (context, _) {
          final totalDuration = markAllReadTotalCount! * 30 + 200;
          final value = markAllReadAnimation!.value;
          final localT =
              (value * totalDuration - markAllReadStaggerIndex! * 30) / 200;
          final localProgress = Curves.easeInOut.transform(
            localT.clamp(0.0, 1.0),
          );
          return _buildContent(context, localProgress);
        },
      );
    }
    return _buildContent(context, null);
  }

  Widget _buildContent(BuildContext context, double? markAllReadProgress) {
    final isUnread = markAllReadProgress != null
        ? markAllReadProgress < 1 && !notification.isRead
        : !notification.isRead;
    final actionLabel = actionLabelForNotificationType(notification.type);
    final backgroundColor = markAllReadProgress != null
        ? Color.lerp(
            const Color(0xFFF5F4F0),
            Colors.white,
            markAllReadProgress,
          )!
        : (isUnread ? const Color(0xFFF5F4F0) : Colors.white);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFFE6F1FB),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: AppColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                (isUnread ||
                    (markAllReadProgress != null && markAllReadProgress < 1))
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationTypeIcon(type: notification.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 13,
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isUnread
                            ? AppColors.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.85),
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notification.orderId != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F1FB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          notification.orderId!,
                          style: AppTextStyles.badgeText.copyWith(
                            color: const Color(0xFF185FA5),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                    if (actionLabel != null) ...[
                      const SizedBox(height: 5),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onActionTap,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            constraints: const BoxConstraints(minHeight: 26),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                actionLabel,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    opacity: markAllReadProgress != null
                        ? (1 - markAllReadProgress)
                        : (isUnread ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatNotificationTimestamp(notification.sentAt),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  final NotificationFilter filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String title;
    String body;
    IconData icon = Icons.notifications_none;
    switch (filter) {
      case NotificationFilter.all:
        title = NotificationConstants.emptyAllTitle;
        body = NotificationConstants.emptyAllBody;
        break;
      case NotificationFilter.payments:
        title = NotificationConstants.emptyPaymentsTitle;
        body = NotificationConstants.emptyPaymentsBody;
        icon = Icons.payment;
        break;
      case NotificationFilter.orderUpdates:
        title = NotificationConstants.emptyOrderUpdatesTitle;
        body = NotificationConstants.emptyOrderUpdatesBody;
        icon = Icons.directions_car_outlined;
        break;
      case NotificationFilter.messages:
        title = NotificationConstants.emptyMessagesTitle;
        body = NotificationConstants.emptyMessagesBody;
        icon = Icons.chat_bubble_outline;
        break;
      case NotificationFilter.alerts:
        title = NotificationConstants.emptyAlertsTitle;
        body = NotificationConstants.emptyAlertsBody;
        break;
    }
    return FadeTransition(
      opacity: const AlwaysStoppedAnimation(1.0),
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.border),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  body,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: _notificationsShellFloatingNavExtra(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _NotificationsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: DashboardLayout.bodyScrollPadding(
          context,
          top: 24,
          bottom: 24 + _notificationsShellFloatingNavExtra(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              NotificationConstants.errorTitle,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              NotificationConstants.errorBody,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(NotificationConstants.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: DashboardLayout.bodyScrollPadding(
        context,
        top: 8,
        bottom: 8 + _notificationsShellFloatingNavExtra(context),
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: Colors.white,
            child: Container(
              height: 88,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          color: AppColors.surface,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 200,
                          color: AppColors.surface,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
