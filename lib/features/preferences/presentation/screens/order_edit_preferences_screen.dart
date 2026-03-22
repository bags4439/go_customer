import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/styled_snackbar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../orders/core/constants/order_edit_constants.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../providers/order_edit_form_provider.dart';
import '../providers/preference_form_provider.dart';

const _kBorderColor = 0xFFE0DFD8;
const _kSurface = 0xFFF5F4F0;
const _kPrimary = 0xFF378ADD;
const _kPrimaryText = 0xFF185FA5;
const _kAmberBg = 0xFFFAEEDA;
const _kAmberBorder = 0xFFBA7517;
const _kAmberText = 0xFF633806;
const _kTextSecondary = 0xFF666666;
const _kTextTertiary = 0xFFAAAAAA;
const _kDisabledBg = 0xFFE0DFD8;

class OrderEditPreferencesScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderEditPreferencesScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderEditPreferencesScreen> createState() =>
      _OrderEditPreferencesScreenState();
}

class _OrderEditPreferencesScreenState
    extends ConsumerState<OrderEditPreferencesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bannerController;
  late Animation<double> _bannerOpacity;
  late Animation<Offset> _bannerSlide;

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _bannerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bannerController, curve: Curves.easeOut),
    );
    _bannerSlide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _bannerController, curve: Curves.easeOut));
    _bannerController.forward();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderProvider(widget.orderId));
    final canEdit = ref.watch(canEditOrderProvider(widget.orderId));

    return orderAsync.when(
      data: (order) {
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order')),
            body: const Center(child: Text('Order not found')),
          );
        }
        if (order.firstPaymentMade) {
          return _AccessDeniedScreen(
            orderId: widget.orderId,
          );
        }
        if (order.isCancelled || order.isCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/order/${widget.orderId}');
          });
          return Scaffold(
            appBar: AppBar(title: const Text(OrderEditConstants.editPreferencesTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return _EditFormContent(
          orderId: widget.orderId,
          canEdit: canEdit,
          bannerOpacity: _bannerOpacity,
          bannerSlide: _bannerSlide,
        );
      },
      loading: () => Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: Text('Unable to load order')),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: Text(
        OrderEditConstants.editPreferencesTitle,
        style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          color: const Color(_kBorderColor),
          height: 0.5,
        ),
      ),
    );
  }
}

class _AccessDeniedScreen extends StatelessWidget {
  final String orderId;

  const _AccessDeniedScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/order/$orderId'),
        ),
        title: Text(
          OrderEditConstants.editPreferencesTitle,
          style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: const Color(_kBorderColor),
            height: 0.5,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(_kSurface),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48, color: Color(_kTextTertiary)),
                const SizedBox(height: 16),
                Text(
                  OrderEditConstants.notAvailable,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  OrderEditConstants.accessDeniedMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(_kTextSecondary),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/order/$orderId'),
                    child: const Text(OrderEditConstants.backToOrder),
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

class _EditFormContent extends ConsumerWidget {
  final String orderId;
  final bool canEdit;
  final Animation<double> bannerOpacity;
  final Animation<Offset> bannerSlide;

  const _EditFormContent({
    required this.orderId,
    required this.canEdit,
    required this.bannerOpacity,
    required this.bannerSlide,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(editFormNotifierProvider(orderId));
    final hasChanges = ref.watch(hasChangesProvider(orderId));
    final agentNameAsync = ref.watch(agentFirstNameProvider(orderId));
    final vehicleOptionsSent = ref.watch(vehicleOptionsSentProvider(orderId));
    final authState = ref.watch(authStateProvider);

    final agentName = agentNameAsync.valueOrNull ?? 'Your agent';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _onBack(context, ref, orderId, hasChanges),
        ),
        title: Text(
          OrderEditConstants.editPreferencesTitle,
          style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: const Color(_kBorderColor),
            height: 0.5,
          ),
        ),
      ),
      body: formState.originalValues == null && formState.error != null
          ? _ErrorRetry(
              message: formState.error!,
              onRetry: () =>
                  ref.read(editFormNotifierProvider(orderId).notifier).load(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeTransition(
                    opacity: bannerOpacity,
                    child: SlideTransition(
                      position: bannerSlide,
                      child: _AgentBanner(
                        message: OrderEditConstants.changesSentToAgent
                            .replaceAll('[agentFirstName]', agentName),
                      ),
                    ),
                  ),
                  if (vehicleOptionsSent.valueOrNull == true) ...[
                    const SizedBox(height: 12),
                    _VehicleOptionsBanner(
                      message: OrderEditConstants.vehicleOptionsWarningEdit
                          .replaceAll('[agentFirstName]', agentName),
                    ),
                  ],
                  if (hasChanges) ...[
                    const SizedBox(height: 12),
                    AnimatedOpacity(
                      opacity: hasChanges ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.1),
                          end: Offset.zero,
                        ).animate(AlwaysStoppedAnimation(hasChanges ? 1.0 : 0.0)),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(_kPrimary),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              OrderEditConstants.unsavedChanges,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: const Color(_kPrimaryText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (formState.originalValues == null) ...[
                    const SizedBox(height: 24),
                    _SectionShimmer(),
                    const SizedBox(height: 12),
                    _SectionShimmer(),
                    const SizedBox(height: 12),
                    _SectionShimmer(),
                  ] else ...[
                    const SizedBox(height: 16),
                    _MakeModelYearSection(orderId: orderId),
                    const SizedBox(height: 12),
                    _ConditionSection(orderId: orderId),
                    const SizedBox(height: 12),
                    _MileageSection(orderId: orderId),
                    const SizedBox(height: 12),
                    _RepairSection(orderId: orderId),
                    const SizedBox(height: 8),
                    _SaveButton(
                      orderId: orderId,
                      hasChanges: hasChanges,
                      isSaving: formState.isSaving,
                      agentName: agentName,
                      userId: authState.value ?? '',
                    ),
                    const SizedBox(height: 10),
                    _DiscardButton(
                      orderId: orderId,
                      hasChanges: hasChanges,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

}

void _onBack(BuildContext context, WidgetRef ref, String orderId, bool hasChanges) {
  if (hasChanges) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(OrderEditConstants.discardConfirmTitle),
        content: const Text(OrderEditConstants.discardConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(OrderEditConstants.keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              OrderEditConstants.discardConfirmAction,
              style: const TextStyle(color: Color(0xFFE24B4A)),
            ),
          ),
        ],
      ),
    ).then((discard) {
      if (discard == true && context.mounted) {
        context.pop();
      }
    });
  } else {
    context.pop();
  }
}

class _AgentBanner extends StatelessWidget {
  final String message;

  const _AgentBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(_kPrimaryText)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(fontSize: 12, color: const Color(_kPrimaryText)),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleOptionsBanner extends StatelessWidget {
  final String message;

  const _VehicleOptionsBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(_kAmberBg),
        border: const Border(left: BorderSide(color: Color(_kAmberBorder), width: 3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 16, color: Color(_kAmberBorder)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(fontSize: 12, color: const Color(_kAmberText)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(_kSurface),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _ChangedBadge extends StatelessWidget {
  final bool show;

  const _ChangedBadge({required this.show});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: show ? 1 : 0,
      duration: Duration(milliseconds: show ? 200 : 150),
      curve: Curves.easeOutBack,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F1FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          OrderEditConstants.changed,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(_kPrimaryText),
          ),
        ),
      ),
    );
  }
}

class _MakeModelYearSection extends ConsumerWidget {
  final String orderId;

  const _MakeModelYearSection({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editFormNotifierProvider(orderId));
    final notifier = ref.read(editFormNotifierProvider(orderId).notifier);
    final o = state.originalValues;
    final makeChanged = o != null && state.make != o.make;
    final modelChanged = o != null && state.model != o.model;
    final yearChanged = o != null &&
        (state.yearMin != o.yearMin || state.yearMax != o.yearMax);
    final models = ref.watch(modelOptionsProvider)[state.make] ?? const ['Other'];

    return _SectionCard(
      sectionLabel: OrderEditConstants.carMake,
      changed: makeChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DropdownRow(
            label: OrderEditConstants.carMake,
            value: state.make,
            options: ref.watch(makeOptionsProvider),
            changed: makeChanged,
            onChanged: (v) {
              if (v != null) notifier.updateMake(v, models);
            },
          ),
          const SizedBox(height: 12),
          _DropdownRow(
            label: OrderEditConstants.model,
            value: state.model,
            options: models,
            changed: modelChanged,
            onChanged: (v) {
              if (v != null) notifier.updateModel(v);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                OrderEditConstants.fromYear,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(_kTextSecondary),
                ),
              ),
              const Spacer(),
              _ChangedBadge(show: yearChanged),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _Dropdown<int>(
                  value: state.yearMin,
                  items: List.generate(15, (i) => 2010 + i),
                  onChanged: (v) {
                    if (v != null) notifier.updateYearMin(v);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Dropdown<int>(
                  value: state.yearMax,
                  items: List.generate(15, (i) => 2010 + i),
                  onChanged: (v) {
                    if (v != null) notifier.updateYearMax(v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: state.isSingleYear
                  ? const Color(0xFFE8F3DF)
                  : const Color(0xFFE6F1FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              state.isSingleYear
                  ? OrderEditConstants.singleYearNote
                  : OrderEditConstants.yearRangeNote,
              style: GoogleFonts.dmSans(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final bool changed;
  final ValueChanged<String?> onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.options,
    required this.changed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(_kTextSecondary),
          ),
        ),
        const SizedBox(width: 8),
        _ChangedBadge(show: changed),
        const Spacer(),
        Expanded(
          flex: 2,
          child: _Dropdown<String>(
            value: value,
            items: options,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(_kBorderColor), width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text('$e'),
                  ))
              .toList(),
          onChanged: (v) => onChanged(v),
        ),
      ),
    );
  }
}

class _ConditionSection extends ConsumerWidget {
  final String orderId;

  const _ConditionSection({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editFormNotifierProvider(orderId));
    final notifier = ref.read(editFormNotifierProvider(orderId).notifier);
    final o = state.originalValues;
    final conditionStr = _conditionToFirestore(state.condition);
    final conditionChanged = o != null && conditionStr != o.condition;

    return _SectionCard(
      sectionLabel: OrderEditConstants.condition,
      changed: conditionChanged,
      child: Column(
        children: [
          _ConditionCard(
            title: OrderEditConstants.readyToDrive,
            subtitle: OrderEditConstants.readyToDriveSub,
            selected: state.condition == PreferenceCondition.readyToDrive,
            onTap: () => notifier.updateCondition(PreferenceCondition.readyToDrive),
          ),
          const SizedBox(height: 8),
          _ConditionCard(
            title: OrderEditConstants.needsModerateRepair,
            subtitle: OrderEditConstants.needsModerateRepairSub,
            selected:
                state.condition == PreferenceCondition.needsModerateRepair,
            onTap: () =>
                notifier.updateCondition(PreferenceCondition.needsModerateRepair),
          ),
          const SizedBox(height: 8),
          _ConditionCard(
            title: OrderEditConstants.fullRebuild,
            subtitle: OrderEditConstants.fullRebuildSub,
            selected:
                state.condition == PreferenceCondition.fullRebuildProject,
            onTap: () =>
                notifier.updateCondition(PreferenceCondition.fullRebuildProject),
          ),
        ],
      ),
    );
  }
}

String _conditionToFirestore(PreferenceCondition c) {
  switch (c) {
    case PreferenceCondition.readyToDrive:
      return 'run_and_drive';
    case PreferenceCondition.needsModerateRepair:
      return 'repairable';
    case PreferenceCondition.fullRebuildProject:
      return 'full_rebuild';
  }
}

class _ConditionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ConditionCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEBF4FD) : Colors.white,
        border: Border.all(
          color: selected ? const Color(_kPrimary) : const Color(_kBorderColor),
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: const Color(_kTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: Color(_kPrimary), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _mileageOptions = [
  (50000, 'Up to 50,000 mi'),
  (70000, 'Up to 70,000 mi'),
  (100000, 'Up to 100,000 mi'),
  (200000, 'No preference'),
];

class _MileageSection extends ConsumerWidget {
  final String orderId;

  const _MileageSection({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editFormNotifierProvider(orderId));
    final notifier = ref.read(editFormNotifierProvider(orderId).notifier);
    final o = state.originalValues;
    final changed = o != null && state.maxMileage != o.maxMileage;

    return _SectionCard(
      sectionLabel: OrderEditConstants.maxMileage,
      changed: changed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _mileageOptions
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SelectableTile(
                    title: e.$2,
                    selected: state.maxMileage == e.$1,
                    onTap: () => notifier.updateMaxMileage(e.$1),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEBF4FD) : Colors.white,
        border: Border.all(
          color: selected ? const Color(_kPrimary) : const Color(_kBorderColor),
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Expanded(child: Text(title, style: GoogleFonts.dmSans(fontSize: 13))),
                if (selected)
                  const Icon(Icons.check_circle, color: Color(_kPrimary), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RepairSection extends ConsumerWidget {
  final String orderId;

  const _RepairSection({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editFormNotifierProvider(orderId));
    final notifier = ref.read(editFormNotifierProvider(orderId).notifier);
    final o = state.originalValues;
    final changed = o != null && state.repairOptedIn != o.repairOptedIn;

    return _SectionCard(
      sectionLabel: OrderEditConstants.repairPreference,
      changed: changed,
      child: Row(
        children: [
          Expanded(
            child: _SelectableTile(
              title: OrderEditConstants.repairYes,
              selected: state.repairOptedIn,
              onTap: () => notifier.updateRepairOptedIn(true),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SelectableTile(
              title: OrderEditConstants.repairNo,
              selected: !state.repairOptedIn,
              onTap: () => notifier.updateRepairOptedIn(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String sectionLabel;
  final bool changed;
  final Widget child;

  const _SectionCard({
    required this.sectionLabel,
    required this.changed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(_kSurface),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                sectionLabel.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(_kTextTertiary),
                ),
              ),
              const SizedBox(width: 8),
              _ChangedBadge(show: changed),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SaveButton extends ConsumerWidget {
  final String orderId;
  final bool hasChanges;
  final bool isSaving;
  final String agentName;
  final String userId;

  const _SaveButton({
    required this.orderId,
    required this.hasChanges,
    required this.isSaving,
    required this.agentName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderGuardAsync = ref.watch(orderProvider(orderId));
    final firstPaymentMade = orderGuardAsync.valueOrNull?.firstPaymentMade ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      child: ElevatedButton(
        onPressed: (hasChanges && !isSaving && userId.isNotEmpty)
            ? () async {
                if (firstPaymentMade) {
                  showErrorSnackBar(
                      context, OrderEditConstants.orderNoLongerCancellable);
                  if (context.mounted) context.pop();
                  return;
                }
                final notifier =
                    ref.read(editFormNotifierProvider(orderId).notifier);
                final ok = await notifier.save(userId);
                if (!context.mounted) return;
                if (ok) {
                  ref.invalidate(orderProvider(orderId));
                  showSuccessSnackBar(
                    context,
                    OrderEditConstants.preferencesSavedSnackbar
                        .replaceAll('[agentFirstName]', agentName),
                  );
                  context.pop();
                } else {
                  showErrorSnackBar(
                      context, OrderEditConstants.couldNotSaveSnackbar);
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasChanges ? const Color(_kPrimary) : const Color(_kDisabledBg),
          foregroundColor: hasChanges ? Colors.white : const Color(_kTextTertiary),
          disabledBackgroundColor: const Color(_kDisabledBg),
          disabledForegroundColor: const Color(_kTextTertiary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                hasChanges
                    ? OrderEditConstants.saveAndNotify.replaceAll(
                        '[agentFirstName]', agentName)
                    : OrderEditConstants.noChangesToSave,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

class _DiscardButton extends ConsumerWidget {
  final String orderId;
  final bool hasChanges;

  const _DiscardButton({
    required this.orderId,
    required this.hasChanges,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          if (hasChanges) {
            showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text(OrderEditConstants.discardConfirmTitle),
                content: const Text(OrderEditConstants.discardConfirmBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text(OrderEditConstants.keepEditing),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      OrderEditConstants.discardConfirmAction,
                      style: const TextStyle(color: Color(0xFFE24B4A)),
                    ),
                  ),
                ],
              ),
            ).then((discard) {
              if (discard == true && context.mounted) {
                context.pop();
              }
            });
          } else {
            context.pop();
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(_kBorderColor)),
          foregroundColor: const Color(_kTextSecondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          OrderEditConstants.discardChanges,
          style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(OrderEditConstants.retry),
            ),
          ],
        ),
      ),
    );
  }
}
