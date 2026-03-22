import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_handler.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/preference_form_provider.dart';

class PreferencesNewScreen extends ConsumerStatefulWidget {
  const PreferencesNewScreen({super.key});

  @override
  ConsumerState<PreferencesNewScreen> createState() => _PreferencesNewScreenState();
}

class _PreferencesNewScreenState extends ConsumerState<PreferencesNewScreen> {
  double _lastCost = 0;
  Color _costFlash = Colors.transparent;

  void _flashCost(double newCost) {
    if (_lastCost == 0) {
      _lastCost = newCost;
      return;
    }
    final diff = newCost - _lastCost;
    _lastCost = newCost;
    setState(() {
      _costFlash = diff >= 0 ? const Color(0xFFFFEBEB) : const Color(0xFFEAF7EE);
    });
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _costFlash = Colors.transparent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preferenceFormProvider);
    final notifier = ref.read(preferenceFormProvider.notifier);
    final estimateAsync = ref.watch(liveCostEstimateProvider);

    estimateAsync.whenData((value) => _flashCost(value.ghs));

    return Scaffold(
      appBar: AppBar(title: const Text('Car preferences')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _ProgressBar(step: state.currentStep),
              const SizedBox(height: 12),
              Expanded(
                child: switch (state.currentStep) {
                  1 => _StepOne(state: state),
                  2 => _StepTwo(
                      state: state,
                      costFlash: _costFlash,
                    ),
                  3 => _StepThree(state: state),
                  4 => _StepFour(state: state),
                  _ => _StepFive(state: state),
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (state.currentStep > 1)
                    Expanded(
                      child: TextButton(
                        onPressed: notifier.previousStep,
                        child: const Text('← Back'),
                      ),
                    ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (state.currentStep < 5) {
                          notifier.nextStep();
                          return;
                        }
                        final router = GoRouter.of(context);
                        final uid = ref.read(authStateProvider).value;
                        if (uid == null) return;
                        final result = await ref
                            .read(createOrderFromPreferencesUseCaseProvider)
                            .call(
                              buyerId: uid,
                              submission: toSubmission(state),
                            );
                        if (!mounted) return;
                        result.fold(
                          (failure) => showFailureSnackBar(context, failure),
                          (orderId) =>
                              router.go('/order/$orderId/agent-connection'),
                        );
                      },
                      child: Text(
                        state.currentStep == 5
                            ? 'Confirm & find my agent →'
                            : 'Next →',
                      ),
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

class _ProgressBar extends StatelessWidget {
  final int step;

  const _ProgressBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final active = index < step;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 4,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF378ADD) : const Color(0xFFD5D5D5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }),
    );
  }
}

class _StepOne extends ConsumerWidget {
  final PreferenceFormState state;

  const _StepOne({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final makeOptions = ref.watch(makeOptionsProvider);
    final modelMap = ref.watch(modelOptionsProvider);
    final models = modelMap[state.make] ?? const ['Other'];
    final years = List.generate(15, (i) => 2010 + i);
    return ListView(
      children: [
        const Text('What car do you want?', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text("Don't worry if you're unsure - your agent will help you refine this."),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: state.make,
          decoration: const InputDecoration(labelText: 'Car make'),
          items: makeOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) {
            if (v != null) {
              ref.read(preferenceFormProvider.notifier).updateMake(v, modelMap[v] ?? ['Other']);
            }
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: state.model,
          decoration: const InputDecoration(labelText: 'Model'),
          items: models.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) {
            if (v != null) ref.read(preferenceFormProvider.notifier).updateModel(v);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: state.yearFrom,
                decoration: const InputDecoration(labelText: 'From year'),
                items: years.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                onChanged: (v) {
                  if (v != null) ref.read(preferenceFormProvider.notifier).updateYearFrom(v);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: state.yearTo,
                decoration: const InputDecoration(labelText: 'To year'),
                items: years.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                onChanged: (v) {
                  if (v != null) ref.read(preferenceFormProvider.notifier).updateYearTo(v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: state.isSingleYear ? const Color(0xFFE8F3DF) : const Color(0xFFE6F1FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            state.isSingleYear
                ? 'Single year selected (${state.yearFrom}) — estimates will show exact amounts'
                : 'Year range selected (${state.yearFrom}-${state.yearTo}) — estimates will show a range',
          ),
        ),
      ],
    );
  }
}

class _StepTwo extends ConsumerWidget {
  final PreferenceFormState state;
  final Color costFlash;
  const _StepTwo({required this.state, required this.costFlash});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimate = ref.watch(liveCostEstimateProvider);
    final mileageStops = const {
      MileageBand.m50k: '50k',
      MileageBand.m70k: '70k',
      MileageBand.m100k: '100k',
      MileageBand.any: 'Any',
    };
    final mileageMessage = switch (state.mileageBand) {
      MileageBand.m50k => 'Lowest mileage, higher price',
      MileageBand.m70k => 'Good balance of price and availability',
      MileageBand.m100k => 'Better price with moderate mileage',
      MileageBand.any => 'Widest options, lowest average pricing',
    };

    return ListView(
      children: [
        estimate.when(
          data: (e) => AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: costFlash == Colors.transparent ? const Color(0xFFF5F4F0) : costFlash,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Estimated total landed cost: ~GHS ${e.ghs.toStringAsFixed(0)}\n'
              '≈ \$${e.usd.toStringAsFixed(0)} at ${e.exchangeRate.toStringAsFixed(2)}',
            ),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Unable to load estimate'),
        ),
        const SizedBox(height: 12),
        _ConditionCard(
          title: 'Ready to drive',
          subtitle: 'Minor cosmetic damage',
          badge: 'Most popular',
          imageUrl: 'https://images.unsplash.com/photo-1549923746-c502d488b3ea',
          selected: state.condition == PreferenceCondition.readyToDrive,
          diff: 'Base estimate',
          onTap: () => ref
              .read(preferenceFormProvider.notifier)
              .updateCondition(PreferenceCondition.readyToDrive),
        ),
        _ConditionCard(
          title: 'Needs moderate repair',
          subtitle: 'Body damage',
          badge: 'Lower price',
          imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf',
          selected: state.condition == PreferenceCondition.needsModerateRepair,
          diff: 'Saves ~GHS 15,000',
          onTap: () => ref
              .read(preferenceFormProvider.notifier)
              .updateCondition(PreferenceCondition.needsModerateRepair),
        ),
        _ConditionCard(
          title: 'Full rebuild project',
          subtitle: 'Major damage',
          badge: 'Lowest price',
          imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70',
          selected: state.condition == PreferenceCondition.fullRebuildProject,
          diff: 'Saves ~GHS 30,000',
          onTap: () => ref
              .read(preferenceFormProvider.notifier)
              .updateCondition(PreferenceCondition.fullRebuildProject),
        ),
        const SizedBox(height: 12),
        Text('Maximum mileage',
            style: Theme.of(context).textTheme.titleMedium),
        Slider(
          divisions: 3,
          min: 0,
          max: 3,
          value: state.mileageBand.index.toDouble(),
          onChanged: (value) {
            ref
                .read(preferenceFormProvider.notifier)
                .updateMileage(MileageBand.values[value.round()]);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: mileageStops.values.map((e) => Text(e)).toList(),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F1FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(mileageMessage),
        )
      ],
    );
  }
}

class _ConditionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final String imageUrl;
  final bool selected;
  final String diff;
  final VoidCallback onTap;
  const _ConditionCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.imageUrl,
    required this.selected,
    required this.diff,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF378ADD) : const Color(0xFFD3D3D3),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: Image.network(
                imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) => Container(
                  height: 110,
                  color: const Color(0xFFF0F0F0),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            ListTile(
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7EE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(badge, style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(height: 6),
                  Text(diff, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepThree extends ConsumerWidget {
  final PreferenceFormState state;
  const _StepThree({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const Text('Repair service', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Would you like us to arrange repairs?'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _RepairChoiceCard(
                selected: state.repairOptedIn,
                title: 'Yes please',
                subtitle: 'Agent arranges repairs at a vetted garage',
                onTap: () => ref.read(preferenceFormProvider.notifier).updateRepairOptedIn(true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RepairChoiceCard(
                selected: !state.repairOptedIn,
                title: 'No thanks',
                subtitle: "I'll handle repairs myself",
                onTap: () => ref.read(preferenceFormProvider.notifier).updateRepairOptedIn(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _InfoBox(
          text:
              'Agent sends quote before work starts. You approve before payment.',
          color: Color(0xFFF5F4F0),
        ),
        const SizedBox(height: 10),
        const _InfoBox(
          text: 'Typical repair cost: GHS 1,500 - 3,500 depending on damage.',
          color: Color(0xFFE6F1FF),
        ),
      ],
    );
  }
}

class _RepairChoiceCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _RepairChoiceCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE6F1FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF378ADD) : const Color(0xFFD3D3D3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  final Color color;
  const _InfoBox({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}

class _StepFour extends ConsumerWidget {
  final PreferenceFormState state;
  const _StepFour({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimate = ref.watch(liveCostEstimateProvider);
    final defaults = ref.watch(costDefaultsProvider).valueOrNull ?? {};
    final serviceFee = defaults['serviceFeeGhs'] ?? 1500;
    return ListView(
      children: [
        const Text('Your cost breakdown', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _TimelineRow(index: 1, label: 'Pay now (deposit + service fee)', color: const Color(0xFF378ADD)),
        _TimelineRow(index: 2, label: 'After bid won (balance + shipping)', color: const Color(0xFFBA7517)),
        _TimelineRow(index: 3, label: 'On arrival at Tema (import duty)', color: const Color(0xFF888888)),
        _TimelineRow(index: 4, label: 'Only if needed (clearance + repairs)', color: const Color(0xFFAAAAAA), optional: true),
        const SizedBox(height: 8),
        _Expander(
          title: '10% deposit',
          subtitle: 'Agent requests',
          expanded: state.expandedDeposit,
          onTap: () => ref.read(preferenceFormProvider.notifier).toggleExpanded('deposit'),
          child: estimate.when(
            data: (e) => Text('Deposit is 10% of estimate: ~GHS ${(e.ghs * 0.10).toStringAsFixed(0)}'),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
        _Expander(
          title: 'Service fee',
          subtitle: 'Agent requests',
          expanded: state.expandedServiceFee,
          onTap: () => ref.read(preferenceFormProvider.notifier).toggleExpanded('service'),
          child: Text('One-time service fee: GHS ${serviceFee.toStringAsFixed(0)}'),
        ),
        _Expander(
          title: 'Vehicle balance + shipping',
          subtitle: 'Deposit deducted here',
          expanded: state.expandedBalanceShipping,
          onTap: () => ref.read(preferenceFormProvider.notifier).toggleExpanded('balance'),
          child: const Text('Remaining purchase and shipping due after bid win.'),
        ),
        _Expander(
          title: 'Import duty',
          subtitle: 'Set by GRA',
          expanded: state.expandedImportDuty,
          onTap: () => ref.read(preferenceFormProvider.notifier).toggleExpanded('duty'),
          child: const Text('GRA duty + levies payable when vehicle arrives.'),
        ),
        _Expander(
          title: 'Port clearance (Optional)',
          subtitle: 'Only if agent clears for you',
          expanded: state.expandedPortClearance,
          onTap: () => ref.read(preferenceFormProvider.notifier).toggleExpanded('clearance'),
          child: const Text('Clearance support fee applies only if you opt in.'),
        ),
        _Expander(
          title: 'Repairs (Optional)',
          subtitle: 'Only if opted in',
          expanded: state.expandedRepairs,
          onTap: () => ref.read(preferenceFormProvider.notifier).toggleExpanded('repairs'),
          child: const Text('Repair cost depends on condition and final quote.'),
        ),
        const SizedBox(height: 10),
        estimate.when(
          data: (e) {
            final deposit = e.ghs * 0.10;
            final upfront = deposit + serviceFee;
            return Column(
              children: [
                _InfoBox(
                  text: 'Minimum you need upfront: ~GHS ${upfront.toStringAsFixed(0)}',
                  color: const Color(0xFFFAEEDA),
                ),
                const SizedBox(height: 8),
                _InfoBox(
                  text: state.isSingleYear
                      ? 'Total estimate: ~GHS ${e.ghs.toStringAsFixed(0)}'
                      : 'Total estimate range depends on year variation.',
                  color: const Color(0xFFF5F4F0),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final int index;
  final String label;
  final Color color;
  final bool optional;
  const _TimelineRow({
    required this.index,
    required this.label,
    required this.color,
    this.optional = false,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(radius: 12, backgroundColor: color.withValues(alpha: 0.2), child: Text('$index', style: const TextStyle(fontSize: 12))),
      title: Text(label),
      subtitle: optional ? const Text('Optional') : null,
    );
  }
}

class _Expander extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;
  const _Expander({
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onTap,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _StepFive extends ConsumerWidget {
  final PreferenceFormState state;
  const _StepFive({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimate = ref.watch(liveCostEstimateProvider);
    final serviceFee = (ref.watch(costDefaultsProvider).valueOrNull?['serviceFeeGhs']) ?? 1500;
    return ListView(
      children: [
        const Text('Review your request', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _kv('Make & model', '${state.make} ${state.model}'),
                _kv('Year', state.isSingleYear ? '${state.yearFrom}' : '${state.yearFrom}-${state.yearTo}'),
                _kv('Condition', state.condition.name),
                _kv('Max mileage', '${toSubmission(state).maxMileage} mi'),
                _kv('Repairs', state.repairOptedIn ? 'Agent handles' : 'Self managed'),
                estimate.when(
                  data: (e) => _kv('Est. total cost', '~GHS ${e.ghs.toStringAsFixed(0)}'),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        estimate.when(
          data: (e) => _InfoBox(
            text:
                'Minimum upfront now: ~GHS ${(e.ghs * 0.10 + serviceFee).toStringAsFixed(0)}',
            color: const Color(0xFFE6F1FF),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 10),
        const _InfoBox(
          text:
              'Once you confirm, an agent is assigned. No payment until agent sends a request.',
          color: Color(0xFFF5F4F0),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(k)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

