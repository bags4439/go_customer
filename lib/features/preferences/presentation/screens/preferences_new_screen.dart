import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/layout/web_app_body.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/preference_form_provider.dart';
import '../widgets/preferences_selections_panel.dart';
import '../widgets/preferences_steps.dart';
import '../widgets/preferences_widgets.dart';

class PreferencesNewScreen extends ConsumerStatefulWidget {
  const PreferencesNewScreen({super.key});

  @override
  ConsumerState<PreferencesNewScreen> createState() =>
      _PreferencesNewScreenState();
}

class _PreferencesNewScreenState extends ConsumerState<PreferencesNewScreen> {
  bool _submitting = false;
  final _budgetFieldKey = GlobalKey<BudgetFieldState>();

  @override
  void initState() {
    super.initState();
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
    setState(() => _submitting = true);

    final rate =
        ref.read(exchangeRateProvider).valueOrNull?.usdToGhs ?? 15.40;

    final result = await ref
        .read(createOrderFromPreferencesUseCaseProvider)
        .call(
          buyerId: uid,
          submission: toSubmission(
            state,
            exchangeRateUsdToGhs: rate,
          ),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => showFailureSnackBar(context, failure),
      (orderId) => router.go('/order/$orderId/agent-connection'),
    );
  }

  Widget _buildStep(PreferenceFormState state) {
    return switch (state.currentStep) {
      1 => PreferenceStepCar(budgetFieldKey: _budgetFieldKey),
      2 => const PreferenceStepReview(),
      _ => PreferenceStepCar(budgetFieldKey: _budgetFieldKey),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preferenceFormProvider);
    final notifier = ref.read(preferenceFormProvider.notifier);
    final isWeb = AppBreakpoints.isWeb(context);

    final body = SafeArea(
      child: Column(
        children: [
          PreferencesStepProgressBar(
            displayStep: state.displayStep,
            totalSteps: state.totalSteps,
            stepLabel: state.progressLabel,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
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

    final scaffold = Scaffold(
      backgroundColor: isWeb ? AppColors.surface : AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            if (state.currentStep == 1) {
              context.pop();
            } else {
              notifier.previousStep();
            }
          },
        ),
        backgroundColor: isWeb ? AppColors.surface : AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 52,
        title: Text(
          'Find your car',
          style: GoogleFonts.dmSans(
            fontSize: AppBreakpoints.scaledFontSize(
              isWeb ? 15 : 17,
              MediaQuery.sizeOf(context).width,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.borderSolid),
        ),
      ),
      body: body,
    );

    if (!isWeb) {
      return PopScope(
        canPop: state.currentStep == 1,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) notifier.previousStep();
        },
        child: scaffold,
      );
    }

    return WebAppBody(
      pageTitle: 'Find your car',
      rightPanel: const PreferencesSelectionsPanel(),
      onBack: state.currentStep == 1
          ? () => context.pop()
          : notifier.previousStep,
      body: body,
    );
  }
}
