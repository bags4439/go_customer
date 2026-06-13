import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/standalone_mobile_screen_scaffold.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_panel_chrome.dart';
import '../../domain/entities/vehicle_option.dart';
import '../providers/vehicle_option_providers.dart';
import '../widgets/listing_source_badge.dart';
import '../widgets/vehicle_option_agent_note.dart';
import '../widgets/vehicle_option_response_badge.dart';
import '../widgets/vehicle_option_response_footer.dart';

class VehicleOptionDetailScreen extends ConsumerWidget {
  const VehicleOptionDetailScreen({
    super.key,
    required this.orderId,
    required this.vehicleOptionId,
    this.embedInWebPanel = false,
    this.onClosePanel,
    this.onBackToList,
  });

  final String orderId;
  final String vehicleOptionId;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;
  final VoidCallback? onBackToList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionAsync = ref.watch(vehicleOptionStreamProvider(vehicleOptionId));
    final orderRef = ref.watch(orderProvider(orderId)).valueOrNull?.orderRef;

    final scaffold = optionAsync.when(
      data: (option) {
        if (option == null || !option.isVisibleToBuyer) {
          return _NotFoundBody(
            orderId: orderId,
            embedInWebPanel: embedInWebPanel,
            onClosePanel: onClosePanel,
          );
        }
        return _DetailBody(
          orderId: orderId,
          option: option,
          embedInWebPanel: embedInWebPanel,
          onClosePanel: onClosePanel,
          onBackToList: onBackToList,
        );
      },
      loading: () => const _DetailShimmer(),
      error: (_, __) => _NotFoundBody(
        orderId: orderId,
        embedInWebPanel: embedInWebPanel,
        onClosePanel: onClosePanel,
      ),
    );

    if (embedInWebPanel) {
      return OrderDetailWebPanelChrome(
        title: 'Option details',
        orderRef: orderRef,
        backLabel: 'All options',
        onBack: onBackToList ?? onClosePanel ?? () {},
        child: scaffold,
      );
    }

    return StandaloneMobileScreenScaffold(
      title: 'Option details',
      onBack: () => context.pop(),
      body: scaffold,
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.orderId,
    required this.option,
    required this.embedInWebPanel,
    this.onClosePanel,
    this.onBackToList,
  });

  final String orderId;
  final VehicleOption option;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;
  final VoidCallback? onBackToList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveLayout.contentMaxWidth(context),
              ),
              child: SingleChildScrollView(
                padding: DashboardLayout.flowContentPadding(context).copyWith(
                  top: embedInWebPanel ? 0 : 16,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            option.displayTitle,
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        VehicleOptionResponseBadge(response: option.buyerResponse),
                      ],
                    ),
                    if (option.source != null) ...[
                      const SizedBox(height: 8),
                      ListingSourceBadge(source: option.source),
                    ],
                    const SizedBox(height: 16),
                    _LinkPreviewCard(
                      listingUrl: option.listingUrl,
                      onOpen: () => _openLink(option.listingUrl),
                    ),
                    if (option.agentNote != null &&
                        option.agentNote!.trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      VehicleOptionAgentNote(
                        vehicleOptionId: option.id,
                        note: option.agentNote!.trim(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _InfoCard(
                      icon: Icons.info_outline_rounded,
                      message:
                          'Review the full details using the link above. '
                          'Marking interest does not commit you to a purchase — '
                          'your agent will follow up in chat.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        VehicleOptionResponseFooter(option: option),
      ],
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _LinkPreviewCard extends StatelessWidget {
  const _LinkPreviewCard({
    required this.listingUrl,
    required this.onOpen,
  });

  final String listingUrl;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final host = _hostLabel(listingUrl);
    final hasUrl = listingUrl.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.infoBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle details',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasUrl ? host : 'Link not available',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: hasUrl ? onOpen : null,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(
                'View details',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _hostLabel(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return url;
    return uri.host;
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.amberBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.amberText,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    Widget box(double h, {double? w}) => Shimmer.fromColors(
          baseColor: AppColors.surface,
          highlightColor: Colors.white,
          child: Container(
            height: h,
            width: w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

    return Padding(
      padding: DashboardLayout.flowScrollPadding(context, top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          box(24, w: 220),
          const SizedBox(height: 16),
          box(140),
          const SizedBox(height: 14),
          box(72),
        ],
      ),
    );
  }
}

class _NotFoundBody extends StatelessWidget {
  const _NotFoundBody({
    required this.orderId,
    required this.embedInWebPanel,
    this.onClosePanel,
  });

  final String orderId;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_car_outlined,
              size: 40,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'Option not found',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This option may have been removed by your agent.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                if (embedInWebPanel) {
                  onClosePanel?.call();
                } else {
                  context.pop();
                }
              },
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
