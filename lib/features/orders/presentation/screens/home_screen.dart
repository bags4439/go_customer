import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../vehicle_options/presentation/providers/vehicle_option_providers.dart';
import '../providers/order_providers.dart';
import '../widgets/home_animated_body.dart';
import '../widgets/home_empty_body.dart';
import '../widgets/home_error_body.dart';
import '../widgets/home_layout_utils.dart';
import '../widgets/home_multi_order.dart';
import '../widgets/home_screen_app_bar.dart';
import '../widgets/home_shimmer.dart';
import '../widgets/home_theme.dart';
import '../widgets/home_web_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerOrdersProvider);
    final currentUserAsync = ref.watch(currentUserProfileProvider);
    final pendingPayments = ref.watch(pendingPaymentCountProvider);
    final pendingReviews = ref.watch(pendingReviewCountProvider);
    final pendingVehicleListings =
        ref.watch(pendingVehicleFeedbackTotalProvider);

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

    final isWeb = AppBreakpoints.isWeb(context);
    const appBar = HomeScreenAppBar();

    final bodyContent = ordersAsync.when(
      data: (orders) => HomeAnimatedBody(
        child: orders.isEmpty
            ? HomeEmptyBody(firstName: homeFirstNameFromUser(currentUserAsync))
            : HomeMultiOrderBody(
                orders: orders,
                pendingPayments: pendingPayments,
                pendingReviews: pendingReviews,
                pendingVehicleListings: pendingVehicleListings,
                currentUserName: currentUserAsync.value?.fullName,
              ),
      ),
      loading: () => const HomeShimmer(),
      error: (_, __) =>
          HomeErrorBody(onRetry: () => ref.invalidate(buyerOrdersProvider)),
    );

    if (isWeb) {
      return HomeWebScaffold(appBar: appBar, body: bodyContent);
    }

    return Scaffold(
      backgroundColor: HomeColors.bgPrimary,
      appBar: appBar,
      body: bodyContent,
    );
  }
}
