import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/styled_snackbar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../core/constants/notification_constants.dart';
import '../../core/utils/notification_timestamp.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_list_item.dart';
import '../providers/notifications_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              NotificationConstants.appBarTitle,
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unreadCount > 0
                  ? '$unreadCount ${NotificationConstants.unreadSuffix}'
                  : NotificationConstants.allCaughtUp,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: unreadCount > 0
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75)
                    : AppColors.success,
              ),
            ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _MarkAllReadButton(onMarkAllRead: _onMarkAllRead),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: AppColors.border,
            height: 0.5,
          ),
        ),
      ),
      body: const _NotificationsBody(),
    );
  }

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
      await ref.read(notificationsNotifierProvider.notifier).markAllRead(unreadIds);
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
}

class _MarkAllReadButton extends ConsumerWidget {
  final Future<void> Function(BuildContext context, WidgetRef ref) onMarkAllRead;

  const _MarkAllReadButton({required this.onMarkAllRead});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inProgress = ref.watch(markAllReadInProgressProvider);
    return SizedBox(
      width: 48,
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
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.secondary,
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

    if (userId == null || userId.isEmpty) {
      return Center(
          child: Text(NotificationConstants.signInPrompt));
    }

    return asyncState.when(
      data: (state) {
        if (state.streamError != null) {
          return _NotificationsError(onRetry: () {
            ref.invalidate(notificationsNotifierProvider);
          });
        }
        return Column(
          children: [
            const _FilterTabs(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: _NotificationsList(key: ValueKey(ref.read(notificationFilterProvider))),
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
    final hasUnreadAll = ref.watch(unreadCountByFilterProvider(NotificationFilter.all));
    final hasUnreadPayments = ref.watch(unreadCountByFilterProvider(NotificationFilter.payments));
    final hasUnreadOrderUpdates = ref.watch(unreadCountByFilterProvider(NotificationFilter.orderUpdates));
    final hasUnreadMessages = ref.watch(unreadCountByFilterProvider(NotificationFilter.messages));
    final hasUnreadAlerts = ref.watch(unreadCountByFilterProvider(NotificationFilter.alerts));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _FilterPill(
            label: NotificationConstants.filterAll,
            isActive: filter == NotificationFilter.all,
            hasUnread: hasUnreadAll,
            onTap: () =>
                ref.read(notificationFilterProvider.notifier).state =
                    NotificationFilter.all,
          ),
          const SizedBox(width: 8),
          _FilterPill(
            label: NotificationConstants.filterPayments,
            isActive: filter == NotificationFilter.payments,
            hasUnread: hasUnreadPayments,
            onTap: () =>
                ref.read(notificationFilterProvider.notifier).state =
                    NotificationFilter.payments,
          ),
          const SizedBox(width: 8),
          _FilterPill(
            label: NotificationConstants.filterOrderUpdates,
            isActive: filter == NotificationFilter.orderUpdates,
            hasUnread: hasUnreadOrderUpdates,
            onTap: () =>
                ref.read(notificationFilterProvider.notifier).state =
                    NotificationFilter.orderUpdates,
          ),
          const SizedBox(width: 8),
          _FilterPill(
            label: NotificationConstants.filterMessages,
            isActive: filter == NotificationFilter.messages,
            hasUnread: hasUnreadMessages,
            onTap: () =>
                ref.read(notificationFilterProvider.notifier).state =
                    NotificationFilter.messages,
          ),
          const SizedBox(width: 8),
          _FilterPill(
            label: NotificationConstants.filterAlerts,
            isActive: filter == NotificationFilter.alerts,
            hasUnread: hasUnreadAlerts,
            onTap: () =>
                ref.read(notificationFilterProvider.notifier).state =
                    NotificationFilter.alerts,
          ),
        ],
      ),
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
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF185FA5)
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.75),
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
  AnimationController? _entranceController;
  int? _entranceEntryCount;
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
    _entranceController?.dispose();
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

    final entryCount =
        items.whereType<NotificationListItemEntry>().length;

    if (items.isNotEmpty && _entranceController == null && entryCount > 0) {
      _entranceEntryCount ??= entryCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _entranceController != null) return;
        final count = _entranceEntryCount!;
        _entranceController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: count * 40 + 200),
        );
        _entranceController!.forward();
        setState(() {});
      });
    }

    if (markAllReadIds != null &&
        markAllReadIds.isNotEmpty &&
        _markAllReadController == null) {
      _markAllReadIds = markAllReadIds;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _markAllReadController != null) return;
        _markAllReadController = AnimationController(
          vsync: this,
          duration: Duration(
              milliseconds: markAllReadIds.length * 30 + 200),
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

    int entryIndex = 0;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                Container(
                  height: 1,
                  width: 40,
                  color: AppColors.border,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    NotificationConstants.noMoreNotifications,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: 40,
                  color: AppColors.border,
                ),
              ],
            ),
          );
        }

        final item = items[index];
        if (item is NotificationListItemSection) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              item.label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFAAAAAA),
              ),
            ),
          );
        }
        final entry = item as NotificationListItemEntry;
        final currentEntryIndex = entryIndex++;
        final markAllReadStaggerIndex = _markAllReadIds?.indexOf(entry.notification.id) ?? -1;
        final markAllReadTotal = _markAllReadIds?.length ?? 0;
        final card = _NotificationItemCard(
          notification: entry.notification,
          onTap: () => _onNotificationTap(context, ref, entry.notification),
          onActionTap: () => _onActionTap(context, ref, entry.notification),
          markAllReadAnimation: _markAllReadController != null && markAllReadStaggerIndex >= 0
              ? _markAllReadController!
              : null,
          markAllReadStaggerIndex: markAllReadStaggerIndex >= 0 ? markAllReadStaggerIndex : null,
          markAllReadTotalCount: markAllReadTotal > 0 ? markAllReadTotal : null,
        );
        Widget child = Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: card,
        );
        if (_entranceController != null && _entranceEntryCount != null) {
          final totalDuration = _entranceEntryCount! * 40 + 200;
          child = AnimatedBuilder(
            animation: _entranceController!,
            builder: (context, _) {
              final value = _entranceController!.value;
              final localT = (value * totalDuration - currentEntryIndex * 40) / 200;
              final curved = Curves.easeOut.transform(localT.clamp(0.0, 1.0));
              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Opacity(
                  opacity: curved,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - curved)),
                    child: card,
                  ),
                ),
              );
            },
          );
        } else {
          child = Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: card,
          );
        }
        return child;
      },
    );
  }

  void _onNotificationTap(
      BuildContext context, WidgetRef ref, NotificationEntity n) {
    ref.read(notificationsNotifierProvider.notifier).markRead(n.id);
    _navigateForNotification(context, n);
  }

  void _onActionTap(
      BuildContext context, WidgetRef ref, NotificationEntity n) {
    ref.read(notificationsNotifierProvider.notifier).markRead(n.id);
    _navigateForNotification(context, n);
  }

  void _navigateForNotification(BuildContext context, NotificationEntity n) {
    final orderId = n.orderId;
    switch (n.type) {
      case 'payment_request':
        final requestId = _extractRequestId(n.actionUrl);
        if (orderId != null && requestId != null) {
          context.push('/order/$orderId/payment-request/$requestId');
        }
        break;
      case 'payment_confirmed':
        if (orderId != null) context.push('/order/$orderId');
        break;
      case 'bid_won':
      case 'bid_lost':
        if (orderId != null) context.push('/order/$orderId/bid-status');
        break;
      case 'stage_update':
      case 'agent_assigned':
      case 'order_edited':
      case 'order_cancelled':
        if (orderId != null) context.push('/order/$orderId');
        break;
      case 'message':
        if (orderId != null) context.push('/order/$orderId?tab=chat');
        break;
      case 'shipping_update':
        if (orderId != null) context.push('/order/$orderId/shipping');
        break;
      case 'arrival':
        if (orderId != null) context.push('/order/$orderId/clearance');
        break;
      case 'id_reminder':
        context.push('/profile/id-verification');
        break;
      case 'system':
        if (orderId != null) context.push('/order/$orderId');
        break;
      default:
        if (orderId != null) context.push('/order/$orderId');
    }
  }

  String? _extractRequestId(String? actionUrl) {
    if (actionUrl == null) return null;
    final parts = actionUrl.split('/payment-request/');
    if (parts.length < 2) return null;
    return parts.last.split('/').first.split('?').first;
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
    final useMarkAllReadAnimation = markAllReadAnimation != null &&
        markAllReadStaggerIndex != null &&
        markAllReadTotalCount != null &&
        markAllReadTotalCount! > 0;
    if (useMarkAllReadAnimation) {
      return AnimatedBuilder(
        animation: markAllReadAnimation!,
        builder: (context, _) {
          final totalDuration =
              markAllReadTotalCount! * 30 + 200;
          final value = markAllReadAnimation!.value;
          final localT = (value * totalDuration -
                  markAllReadStaggerIndex! * 30) /
              200;
          final localProgress =
              Curves.easeInOut.transform(localT.clamp(0.0, 1.0));
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
    final actionLabel = _actionLabelForType(notification.type);
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
            boxShadow: (isUnread ||
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
              _NotificationIcon(type: notification.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                        color: isUnread
                            ? AppColors.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.75),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notification.orderId != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F1FB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          notification.orderId!,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF185FA5),
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
                                horizontal: 9, vertical: 3),
                            constraints: const BoxConstraints(minHeight: 26),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                actionLabel,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
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
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
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

  String? _actionLabelForType(String type) {
    switch (type) {
      case 'payment_request':
        return NotificationConstants.actionPayNow;
      case 'shipping_update':
        return NotificationConstants.actionTrack;
      case 'arrival':
        return NotificationConstants.actionClearance;
      case 'bid_won':
        return NotificationConstants.actionViewDetails;
      case 'id_reminder':
        return NotificationConstants.actionVerifyNow;
      case 'message':
        return NotificationConstants.actionViewMessage;
      case 'agent_assigned':
        return NotificationConstants.actionMeetAgent;
      default:
        return null;
    }
  }
}

class _NotificationIcon extends StatelessWidget {
  final String type;

  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Widget content;
    switch (type) {
      case 'payment_request':
      case 'payment_confirmed':
        bgColor = const Color(0xFFE6F1FB);
        content = Text(
          '₵',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF185FA5),
          ),
        );
        break;
      case 'bid_won':
        bgColor = const Color(0xFFEAF3DE);
        content = const Text('🎉', style: TextStyle(fontSize: 15));
        break;
      case 'bid_lost':
        bgColor = AppColors.surface;
        content = const Text('😔', style: TextStyle(fontSize: 15));
        break;
      case 'shipping_update':
      case 'arrival':
        bgColor = const Color(0xFFE1F5EE);
        content = const Text('🚢', style: TextStyle(fontSize: 15));
        break;
      case 'message':
        bgColor = AppColors.surface;
        content = Icon(
          Icons.chat_bubble_outline,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
        );
        break;
      case 'agent_assigned':
        bgColor = const Color(0xFFE6F1FB);
        content = const Icon(
          Icons.person_outline,
          size: 16,
          color: Color(0xFF185FA5),
        );
        break;
      case 'order_edited':
      case 'order_cancelled':
        bgColor = const Color(0xFFFAEEDA);
        content = const Icon(
          Icons.edit_outlined,
          size: 16,
          color: Color(0xFF633806),
        );
        break;
      case 'inactivity_reminder':
      case 'auction_deadline':
        bgColor = const Color(0xFFFAEEDA);
        content = Text(
          '!',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.warning,
          ),
        );
        break;
      case 'id_reminder':
      case 'system':
      default:
        bgColor = AppColors.surface;
        content = Icon(
          Icons.info_outline,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
        );
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: content,
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
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  body,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_outlined,
                size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              NotificationConstants.errorTitle,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              NotificationConstants.errorBody,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
