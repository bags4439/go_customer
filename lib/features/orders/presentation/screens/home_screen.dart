import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../referral/presentation/widgets/referral_promo_card.dart';
import '../../../guide/core/constants/guide_keys.dart';
import '../../../guide/presentation/widgets/coach_mark_card.dart';
import '../../../guide/presentation/widgets/coach_mark_overlay.dart';
import '../../../guide/presentation/widgets/guide_faq_sheet.dart';
import '../../../guide/presentation/widgets/spotlight_painter.dart';
import '../../../support/presentation/widgets/support_bottom_sheet.dart';
import '../providers/order_providers.dart';

part '../widgets/home_theme.dart';
part '../widgets/home_animated_body.dart';
part '../widgets/home_shimmer.dart';
part '../widgets/home_error.dart';
part '../widgets/home_empty.dart';
part '../widgets/home_metric_card.dart';
part '../widgets/home_order_card.dart';
part '../widgets/home_staggered_item.dart';
part '../widgets/home_multi_order.dart';

String? _firstNameFromUser(AsyncValue<dynamic> userAsync) {
  return userAsync.maybeWhen(
    data: (user) {
      if (user == null) return null;
      final dynamic u = user;
      final name = u.fullName;
      if (name is! String || name.trim().isEmpty) return null;
      final parts = name
          .trim()
          .split(RegExp(r'\s+'))
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.isEmpty) return null;
      return parts.first;
    },
    orElse: () => null,
  );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerOrdersProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final pendingPayments = ref.watch(pendingPaymentCountProvider);

    ordersAsync.whenOrNull(
      error: (error, stack) {
        showFailureSnackBar(
          context,
          UnexpectedFailure(
            message: 'Could not load your orders.',
            cause: error,
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: _C.bgPrimary,
      appBar: _buildAppBar(context),
      body: ordersAsync.when(
        data: (orders) => _AnimatedBody(
          child: orders.isEmpty
              ? _EmptyHome(firstName: _firstNameFromUser(currentUserAsync))
              : _MultiOrderHome(
                  orders: orders,
                  pendingPayments: pendingPayments,
                  currentUserName: currentUserAsync.value?.fullName,
                ),
        ),
        loading: () => const _HomeShimmer(),
        error: (_, __) =>
            _ErrorHome(onRetry: () => ref.invalidate(buyerOrdersProvider)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _C.bgPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: const _AppLogo(),
      actions: [
        IconButton(
          icon: const Icon(Icons.headset_mic_rounded, size: 22),
          color: AppColors.textSecondary,
          tooltip: 'Support',
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.only(right: 16),
          ),
          onPressed: () => SupportBottomSheet.show(context),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: _C.border),
      ),
    );
  }
}
