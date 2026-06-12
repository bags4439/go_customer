import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/models/currency_model.dart';
import '../../domain/entities/repair_job.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import 'repair_complete_delivery_card.dart';
import 'repair_complete_hero.dart';
import 'repair_complete_photos_row.dart';
import 'repair_complete_work_card.dart';
import 'repair_photo_item.dart';

class RepairCompleteState extends ConsumerStatefulWidget {
  const RepairCompleteState({
    super.key,
    required this.orderId,
    required this.job,
    required this.currency,
    this.onOpenDelivery,
  });

  final String orderId;
  final RepairJob job;
  final CurrencyModel currency;
  final VoidCallback? onOpenDelivery;

  @override
  ConsumerState<RepairCompleteState> createState() =>
      _RepairCompleteStateState();
}

class _RepairCompleteStateState extends ConsumerState<RepairCompleteState> {
  final List<bool> _sectionVisible = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) setState(() => _sectionVisible[i] = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentName =
        ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ??
        'Your agent';
    final order = ref.watch(orderProvider(widget.orderId)).valueOrNull;
    final makeModel = [
      order?.make,
      order?.model,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    final displayMakeModel = makeModel.isEmpty ? 'vehicle' : makeModel;
    final allPhotos = [
      ...widget.job.beforePhotoUrls.map((u) => RepairPhotoItem(u, true)),
      ...widget.job.afterPhotoUrls.map((u) => RepairPhotoItem(u, false)),
    ];

    return SingleChildScrollView(
      padding: DashboardLayout.flowScrollPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: _sectionVisible[0] ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Transform.translate(
              offset: Offset(0, _sectionVisible[0] ? 0 : 12),
              child: RepairCompleteHero(
                actualCompletion: widget.job.actualCompletion,
                makeModel: displayMakeModel,
              ),
            ),
          ),
          if (_sectionVisible[1]) ...[
            const SizedBox(height: 20),
            RepairCompletePhotosRow(photos: allPhotos, jobId: widget.job.id),
          ],
          if (_sectionVisible[2]) ...[
            const SizedBox(height: 20),
            RepairCompleteWorkCard(job: widget.job, currency: widget.currency),
          ],
          if (_sectionVisible[3]) ...[
            const SizedBox(height: 12),
            RepairCompleteDeliveryCard(
              orderId: widget.orderId,
              agentName: agentName,
              onOpenDelivery: widget.onOpenDelivery,
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
