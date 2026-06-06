import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/route_constants.dart';
import 'core/layout/app_breakpoints.dart';
import 'core/widgets/buyer_dashboard_shell.dart';
import 'features/auth/presentation/screens/account_created_screen.dart';
import 'features/auth/presentation/screens/id_upload_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/bids/presentation/screens/bid_status_screen.dart';
import 'features/clearance/presentation/screens/clearance_screen.dart';
import 'features/delivery/presentation/screens/delivery_screen.dart';
import 'features/documents/presentation/screens/document_detail_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/orders/presentation/screens/home_screen.dart';
import 'features/orders/presentation/screens/agent_connection_screen.dart';
import 'features/orders/presentation/screens/order_cancel_screen.dart';
import 'features/orders/presentation/screens/order_cancelled_screen.dart';
import 'features/orders/presentation/screens/buyer_review_screen.dart';
import 'features/orders/presentation/screens/order_detail_screen.dart';
import 'features/preferences/presentation/screens/order_edit_preferences_screen.dart';
import 'features/payments/presentation/screens/payment_request_view_screen.dart';
import 'features/payments/presentation/screens/payment_processing_screen.dart';
import 'features/payments/presentation/screens/payment_confirmed_screen.dart';
import 'features/preferences/presentation/screens/preferences_new_screen.dart';
import 'features/profile/presentation/screens/id_verification_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/repairs/presentation/screens/repair_screen.dart';
import 'features/shipping/presentation/screens/shipping_screen.dart';
import 'features/vehicle_options/presentation/screens/vehicle_option_detail_screen.dart';
import 'features/vehicle_options/presentation/screens/vehicle_options_list_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final location = state.matchedLocation;
    final guestOnlyPaths = <String>{
      '/splash',
      '/onboarding',
      '/register',
      '/otp',
    };
    if (user == null &&
        !guestOnlyPaths.contains(location) &&
        location != '/id-upload' &&
        location != '/account-created') {
      return '/login';
    }
    if (user != null && guestOnlyPaths.contains(location)) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      name: RouteConstants.splash,
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: RouteConstants.onboarding,
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      name: RouteConstants.login,
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: RouteConstants.register,
      path: '/register',
      redirect: (_, __) => '/login',
    ),
    GoRoute(
      name: RouteConstants.otpVerification,
      path: '/otp',
      redirect: (_, __) => '/login',
    ),
    GoRoute(
      name: RouteConstants.idUpload,
      path: '/id-upload',
      builder: (context, state) => const IdUploadScreen(),
    ),
    GoRoute(
      name: RouteConstants.accountCreated,
      path: '/account-created',
      builder: (context, state) => const AccountCreatedScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BuyerDashboardShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: RouteConstants.home,
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: RouteConstants.notifications,
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: RouteConstants.profile,
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: RouteConstants.preferencesNew,
              path: '/preferences/new',
              builder: (context, state) => const PreferencesNewScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      name: RouteConstants.orderDetail,
      path: '/order/:orderId',
      builder: (context, state) => OrderDetailScreen(
        orderId: state.pathParameters['orderId']!,
        initialTab: state.uri.queryParameters['tab'] ?? 'overview',
        initialPaymentRequestId:
            state.uri.queryParameters[RouteConstants.paymentRequestQuery],
        initialReviewPanel:
            state.uri.queryParameters[RouteConstants.reviewPanelQuery],
      ),
      routes: [
        GoRoute(
          name: RouteConstants.agentConnection,
          path: 'agent-connection',
          builder: (context, state) =>
              AgentConnectionScreen(orderId: state.pathParameters['orderId']!),
        ),
        GoRoute(
          name: RouteConstants.paymentRequest,
          path: 'payment-request/:requestId',
          redirect: (context, state) {
            if (!AppBreakpoints.isWeb(context)) return null;
            final orderId = state.pathParameters['orderId']!;
            final requestId = state.pathParameters['requestId']!;
            return '/order/$orderId'
                '?${RouteConstants.paymentRequestQuery}=$requestId';
          },
          builder: (context, state) => PaymentRequestViewScreen(
            orderId: state.pathParameters['orderId']!,
            requestId: state.pathParameters['requestId']!,
          ),
          routes: [
            GoRoute(
              name: RouteConstants.paymentProcessing,
              path: 'processing',
              builder: (context, state) {
                final paymentId = state.uri.queryParameters['paymentId'] ?? '';
                return PaymentProcessingScreen(
                  orderId: state.pathParameters['orderId']!,
                  requestId: state.pathParameters['requestId']!,
                  paymentId: paymentId,
                );
              },
            ),
            GoRoute(
              name: RouteConstants.paymentConfirmed,
              path: 'confirmed',
              builder: (context, state) {
                final paymentId = state.uri.queryParameters['paymentId'] ?? '';
                return PaymentConfirmedScreen(
                  orderId: state.pathParameters['orderId']!,
                  requestId: state.pathParameters['requestId']!,
                  paymentId: paymentId,
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: RouteConstants.shipping,
          path: 'shipping',
          builder: (context, state) =>
              ShippingScreen(orderId: state.pathParameters['orderId']!),
        ),
        GoRoute(
          name: RouteConstants.clearance,
          path: 'clearance',
          builder: (context, state) =>
              ClearanceScreen(orderId: state.pathParameters['orderId']!),
        ),
        GoRoute(
          name: RouteConstants.repair,
          path: 'repair',
          builder: (context, state) =>
              RepairScreen(orderId: state.pathParameters['orderId']!),
        ),
        GoRoute(
          name: RouteConstants.delivery,
          path: 'delivery',
          builder: (context, state) =>
              DeliveryScreen(orderId: state.pathParameters['orderId']!),
        ),
        GoRoute(
          name: RouteConstants.orderReview,
          path: 'review',
          builder: (context, state) =>
              BuyerReviewScreen(orderId: state.pathParameters['orderId']!),
        ),
        GoRoute(
          name: RouteConstants.bidStatus,
          path: 'bid-status',
          builder: (context, state) =>
              BidStatusScreen(orderId: state.pathParameters['orderId']!),
        ),
        GoRoute(
          name: RouteConstants.vehicleOptionsList,
          path: 'vehicle-options',
          builder: (context, state) => VehicleOptionsListScreen(
            orderId: state.pathParameters['orderId']!,
          ),
        ),
        GoRoute(
          name: RouteConstants.vehicleDetail,
          path: 'vehicle/:vehicleOptionId',
          builder: (context, state) => VehicleOptionDetailScreen(
            orderId: state.pathParameters['orderId']!,
            vehicleOptionId: state.pathParameters['vehicleOptionId']!,
          ),
        ),
        GoRoute(
          name: RouteConstants.documentDetail,
          path: 'documents/:documentId',
          builder: (context, state) => DocumentDetailScreen(
            orderId: state.pathParameters['orderId']!,
            documentId: state.pathParameters['documentId']!,
          ),
        ),
        GoRoute(
          name: RouteConstants.orderPreferencesEdit,
          path: 'preferences/edit',
          builder: (context, state) => OrderEditPreferencesScreen(
            orderId: state.pathParameters['orderId']!,
          ),
        ),
        GoRoute(
          name: RouteConstants.orderCancel,
          path: 'cancel',
          builder: (context, state) =>
              OrderCancelScreen(orderId: state.pathParameters['orderId']!),
        ),
        GoRoute(
          name: RouteConstants.orderCancelled,
          path: 'cancelled',
          builder: (context, state) =>
              OrderCancelledScreen(orderId: state.pathParameters['orderId']!),
        ),
      ],
    ),
    GoRoute(
      name: RouteConstants.preferencesEdit,
      path: '/preferences/edit/:orderId',
      builder: (context, state) =>
          OrderEditPreferencesScreen(orderId: state.pathParameters['orderId']!),
    ),
    GoRoute(
      name: RouteConstants.idVerification,
      path: '/profile/id-verification',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const IdVerificationScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: Center(child: Text(state.error?.toString() ?? 'Route not found')),
  ),
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
