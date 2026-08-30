import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/card_container.dart';
import '../providers/order_creation_context.dart';

class OrderCreationStartScreen extends ConsumerWidget {
  const OrderCreationStartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = ref.watch(canCreateOrdersForCustomersProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(title: const Text('Create order')),
      body: permission.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _StartChoices(showAssisted: false),
        data: (allowed) {
          if (!allowed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.pushReplacement('/preferences/new');
              }
            });
            return const Center(child: CircularProgressIndicator());
          }
          return const _StartChoices(showAssisted: true);
        },
      ),
    );
  }
}

class _StartChoices extends StatelessWidget {
  const _StartChoices({required this.showAssisted});
  final bool showAssisted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            Text('Who is this order for?', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Choose whose account should own and manage the order.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _ChoiceCard(
              icon: Icons.person_outline,
              title: 'For myself',
              subtitle: 'Create a personal import order using your account.',
              onTap: () => context.push('/preferences/new'),
            ),
            if (showAssisted) ...[
              const SizedBox(height: 14),
              _ChoiceCard(
                icon: Icons.group_add_outlined,
                title: 'For another customer',
                subtitle: 'Find a registered customer by phone number.',
                onTap: () => context.push('/preferences/customer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: CardContainer(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.brandMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.brand),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.brand,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
