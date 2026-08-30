import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/layout/web_app_body.dart';
import '../../../../core/layout/web_app_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dashboard_mobile_app_bar.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/preference_form_provider.dart';
import '../providers/order_creation_context.dart';
import '../widgets/preferences_steps.dart';
import '../widgets/preferences_widgets.dart';

class PreferencesNewScreen extends ConsumerStatefulWidget {
  const PreferencesNewScreen({super.key, this.assisted = false});
  final bool assisted;

  @override
  ConsumerState<PreferencesNewScreen> createState() =>
      _PreferencesNewScreenState();
}

class _PreferencesNewScreenState extends ConsumerState<PreferencesNewScreen> {
  bool _submitting = false;
  late final String _idempotencyKey;
  final _budgetFieldKey = GlobalKey<BudgetFieldState>();

  @override
  void initState() {
    super.initState();
    _idempotencyKey =
        '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(preferenceFormProvider.notifier).reset();
    });
  }

  void _commitBudget() => _budgetFieldKey.currentState?.commit();

  Future<void> _onConfirm(
    BuildContext context,
    PreferenceFormState state,
  ) async {
    final router = GoRouter.of(context);
    final uid = ref.read(authStateProvider).value;
    if (uid == null) return;
    final assistedCustomer = ref.read(assistedCustomerProvider);
    if (widget.assisted && assistedCustomer == null) {
      context.go('/preferences/customer');
      return;
    }
    setState(() => _submitting = true);

    final rate = ref.read(exchangeRateProvider).valueOrNull?.usdToGhs ?? 15.40;

    final result = await ref
        .read(createOrderFromPreferencesUseCaseProvider)
        .call(
          buyerId: uid,
          submission: toSubmission(state, exchangeRateUsdToGhs: rate),
          idempotencyKey: _idempotencyKey,
          assistedCustomerPhone: widget.assisted
              ? assistedCustomer?.phone
              : null,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold((failure) => showFailureSnackBar(context, failure), (orderId) {
      if (widget.assisted) {
        router.go('/preferences/assisted/success');
      } else {
        router.go('/order/$orderId/agent-connection');
      }
    });
  }

  Widget _buildStep(PreferenceFormState state) {
    return switch (state.currentStep) {
      1 => PreferenceStepCar(budgetFieldKey: _budgetFieldKey),
      2 => const PreferenceStepReview(),
      _ => PreferenceStepCar(budgetFieldKey: _budgetFieldKey),
    };
  }

  Widget _buildBody(
    PreferenceFormState state,
    PreferenceFormNotifier notifier,
  ) {
    return SafeArea(
      child: Column(
        children: [
          PreferencesStepProgressBar(
            displayStep: state.displayStep,
            totalSteps: state.totalSteps,
            stepLabel: state.progressLabel,
          ),
          if (widget.assisted) const _AssistedCustomerBanner(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(state.currentStep),
                child: _buildStep(state),
              ),
            ),
          ),
          PreferencesBottomNavBar(
            state: state,
            notifier: notifier,
            isLoading: _submitting,
            onBeforeAction: _commitBudget,
            onConfirm: () =>
                _onConfirm(context, ref.read(preferenceFormProvider)),
          ),
        ],
      ),
    );
  }

  void _onBack(PreferenceFormState state, PreferenceFormNotifier notifier) {
    if (state.currentStep == 1) {
      context.pop();
    } else {
      notifier.previousStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preferenceFormProvider);
    final notifier = ref.read(preferenceFormProvider.notifier);
    final isWeb = AppBreakpoints.useWebShell(context);
    final body = _buildBody(state, notifier);

    if (isWeb) {
      return WebAppShell(
        activeRoute: '/home',
        child: WebAppBody(
          pageTitle: 'Find your car',
          showRightPanel: true,
          onBack: () => _onBack(state, notifier),
          body: body,
        ),
      );
    }

    return PopScope(
      canPop: state.currentStep == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) notifier.previousStep();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        resizeToAvoidBottomInset: false,
        appBar: DashboardMobileTitleAppBar(
          title: 'Find your car',
          onBack: () => _onBack(state, notifier),
          titleStyle: dashboardMobileFlowTitleStyle(),
        ),
        body: DashboardPortraitFrame(child: body),
      ),
    );
  }
}

class _AssistedCustomerBanner extends ConsumerWidget {
  const _AssistedCustomerBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(assistedCustomerProvider);
    if (customer == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.brandMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.filterActiveBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.brand, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Creating for ${customer.fullName} · ${customer.maskedPhone}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
