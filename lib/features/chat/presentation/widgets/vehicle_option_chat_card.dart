import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../vehicles/core/constants/vehicle_detail_constants.dart';
import '../../../vehicles/domain/entities/vehicle_option_entity.dart';
import '../../../vehicles/presentation/providers/vehicle_detail_providers.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../constants/vehicle_chat_card_constants.dart';

const _kBorder = Color(0xFFE0DFD8);
const _kPrimary = Color(0xFF378ADD);
const _kSuccess = Color(0xFF1D9E75);
const _kTextPrimary = Color(0xDE000000);
const _kTextSecondary = Color(0xFF666666);
const _kTextTertiary = Color(0xFFAAAAAA);
const _kAmberBg = Color(0xFFFAEEDA);
const _kAmberText = Color(0xFF633806);
const _kWarn = Color(0xFFBA7517);
const _kSurface = Color(0xFFF5F4F0);
const _kNoteBg = Color(0xFFF9F8F5);
const _kNoteAccent = Color(0xFF185FA5);
const _kRunDriveBg = Color(0xFFEAF3DE);
const _kRunDriveFg = Color(0xFF27500A);
const _kRepairBg = Color(0xFFFAEEDA);
const _kRepairFg = Color(0xFF633806);
const _kRebuildBg = Color(0xFFFCEBEB);
const _kRebuildFg = Color(0xFFA32D2D);
const _kBinPillBg = Color(0xFFE6F1FB);
const _kBinPillFg = Color(0xFF185FA5);

/// In-chat vehicle option card with live Firestore data (display-only).
class VehicleOptionChatCard extends ConsumerStatefulWidget {
  const VehicleOptionChatCard({
    super.key,
    required this.orderId,
    required this.vehicleOptionId,
  });

  final String orderId;
  final String vehicleOptionId;

  @override
  ConsumerState<VehicleOptionChatCard> createState() =>
      _VehicleOptionChatCardState();
}

class _VehicleOptionChatCardState extends ConsumerState<VehicleOptionChatCard> {
  late final PageController _pageController;
  int _pageIndex = 0;
  bool _damageExpanded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voAsync = ref.watch(vehicleOptionStreamProvider(widget.vehicleOptionId));

    return voAsync.when(
      data: (vo) {
        if (vo == null) return const SizedBox.shrink();
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: _CardChrome(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PhotoGallery(
                    urls: _photoUrls(vo),
                    pageController: _pageController,
                    pageIndex: _pageIndex,
                    onPageChanged: (i) => setState(() => _pageIndex = i),
                  ),
                  _VehicleHeader(vo: vo),
                  _DamageSection(
                    vo: vo,
                    expanded: _damageExpanded,
                    onToggleExpand: () =>
                        setState(() => _damageExpanded = !_damageExpanded),
                  ),
                  if (vo.agentNote != null && vo.agentNote!.trim().isNotEmpty)
                    _AgentNoteBlock(
                      vehicleOptionId: widget.vehicleOptionId,
                      note: vo.agentNote!.trim(),
                    ),
                  _PricingSummarySection(vo: vo),
                  _ChatLinkSection(orderId: widget.orderId),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: const _VehicleCardShimmer(),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

List<String> _photoUrls(VehicleOptionEntity vo) {
  if (vo.photoUrls.isNotEmpty) return vo.photoUrls;
  if (vo.photoUrl != null && vo.photoUrl!.isNotEmpty) return [vo.photoUrl!];
  return const [];
}

class _CardChrome extends StatelessWidget {
  const _CardChrome({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({
    required this.urls,
    required this.pageController,
    required this.pageIndex,
    required this.onPageChanged,
  });

  final List<String> urls;
  final PageController pageController;
  final int pageIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return const SizedBox(
        height: 180,
        width: double.infinity,
        child: ColoredBox(
          color: _kSurface,
          child: Icon(Icons.directions_car_outlined, size: 48, color: _kTextTertiary),
        ),
      );
    }
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: urls.length,
            itemBuilder: (context, i) {
              return CachedNetworkImage(
                imageUrl: urls[i],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(color: Colors.white, height: 180),
                ),
                errorWidget: (context, url, error) => const ColoredBox(
                  color: _kSurface,
                  child: Icon(Icons.directions_car_outlined, size: 48, color: _kTextTertiary),
                ),
              );
            },
          ),
          if (urls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final active = i == pageIndex;
                  return Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: active ? 8 : 6,
                      height: active ? 8 : 6,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(active ? 4 : 3),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _VehicleHeader extends StatelessWidget {
  const _VehicleHeader({required this.vo});

  final VehicleOptionEntity vo;

  @override
  Widget build(BuildContext context) {
    final title = _titleText(vo);
    final source = (vo.source ?? '').toLowerCase();
    final sourceLabel = source == 'iaa'
        ? VehicleDetailConstants.sourceIaa
        : VehicleDetailConstants.sourceCopart;
    final loc = vo.auctionLocation?.trim().isNotEmpty == true
        ? vo.auctionLocation!
        : '—';
    final dateSuffix = vo.isBuyItNow || vo.auctionDate == null
        ? ''
        : ' · ${VehicleDetailConstants.auctionLabel}: ${DateFormatter.format(vo.auctionDate)}';
    final sub = '$sourceLabel · $loc$dateSuffix';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isEmpty ? '—' : title,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _kTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _conditionPill(vo.condition),
                if (vo.mileage != null) ...[
                  const SizedBox(width: 6),
                  _mileagePill(vo.mileage!),
                ],
                if (vo.isBuyItNow) ...[
                  const SizedBox(width: 6),
                  _buyItNowPill(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titleText(VehicleOptionEntity vo) {
    if (vo.yearMakeModel != null && vo.yearMakeModel!.trim().isNotEmpty) {
      return vo.yearMakeModel!.trim();
    }
    final parts = <String>[];
    if (vo.year != null) parts.add('${vo.year}');
    if (vo.make != null && vo.make!.isNotEmpty) parts.add(vo.make!);
    if (vo.model != null && vo.model!.isNotEmpty) parts.add(vo.model!);
    if (vo.trim != null && vo.trim!.isNotEmpty) parts.add(vo.trim!);
    return parts.join(' ');
  }

  Widget _conditionPill(String? condition) {
    final c = (condition ?? '').toLowerCase();
    Color bg;
    Color fg;
    String label;
    switch (c) {
      case 'repairable':
        bg = _kRepairBg;
        fg = _kRepairFg;
        label = VehicleChatCardConstants.repairable;
      case 'full_rebuild':
        bg = _kRebuildBg;
        fg = _kRebuildFg;
        label = VehicleChatCardConstants.fullRebuild;
      default:
        bg = _kRunDriveBg;
        fg = _kRunDriveFg;
        label = VehicleChatCardConstants.runAndDrive;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }

  Widget _mileagePill(int mileage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      child: Text(
        '${NumberFormat.decimalPattern().format(mileage)}${VehicleChatCardConstants.mileageSuffix}',
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _kTextPrimary,
        ),
      ),
    );
  }

  Widget _buyItNowPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _kBinPillBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      child: Text(
        'Buy It Now',
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _kBinPillFg,
        ),
      ),
    );
  }
}

class _DamageSection extends StatelessWidget {
  const _DamageSection({
    required this.vo,
    required this.expanded,
    required this.onToggleExpand,
  });

  final VehicleOptionEntity vo;
  final bool expanded;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final desc = vo.damageDescription?.trim() ?? '';
    final showClean = !vo.hasVehicleDamage;
    final showDamage = vo.hasVehicleDamage && desc.isNotEmpty;

    if (!showClean && !showDamage) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: showClean
            ? Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: _kSuccess),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        VehicleChatCardConstants.cleanVehicle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _kSuccess,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _ExpandableDamageText(
                description: desc,
                expanded: expanded,
                onToggleExpand: onToggleExpand,
              ),
      ),
    );
  }
}

class _ExpandableDamageText extends StatelessWidget {
  const _ExpandableDamageText({
    required this.description,
    required this.expanded,
    required this.onToggleExpand,
  });

  final String description;
  final bool expanded;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          VehicleChatCardConstants.damageLabel,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: _kTextTertiary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final style = GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: _kTextSecondary,
                height: 1.5,
              );
              final textPainter = TextPainter(
                text: TextSpan(text: description, style: style),
                maxLines: 3,
                textDirection: ui.TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);
              final overflow = textPainter.didExceedMaxLines;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      maxLines: expanded ? null : 3,
                      overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: style,
                    ),
                    if (overflow && !expanded)
                      GestureDetector(
                        onTap: onToggleExpand,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            VehicleChatCardConstants.showMore,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _kNoteAccent,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AgentNoteBlock extends ConsumerWidget {
  const _AgentNoteBlock({
    required this.vehicleOptionId,
    required this.note,
  });

  final String vehicleOptionId;
  final String note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentForVehicleProvider(vehicleOptionId));
    final title = agentAsync.when(
      data: (a) {
        final first = a?.firstName;
        if (first != null && first.isNotEmpty) {
          return "$first${VehicleChatCardConstants.agentNoteTitleSuffix}";
        }
        return VehicleChatCardConstants.agentNoteFallback;
      },
      loading: () => VehicleChatCardConstants.agentNoteFallback,
      error: (_, __) => VehicleChatCardConstants.agentNoteFallback,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        decoration: const BoxDecoration(
          color: _kNoteBg,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
          border: Border(
            left: BorderSide(color: _kPrimary, width: 3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _kNoteAccent,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              note,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: _kTextSecondary,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingSummarySection extends ConsumerWidget {
  const _PricingSummarySection({required this.vo});

  final VehicleOptionEntity vo;

  String _rateUnavailable() => VehicleDetailConstants.rateUnavailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rateAsync = ref.watch(exchangeRateProvider);
    final rate = rateAsync.valueOrNull?.usdToGhs;
    final rOk = rate != null && rate > 0;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1, thickness: 0.5, color: _kBorder),
          Padding(
            padding: const EdgeInsets.all(12),
            child: vo.isBuyItNow ? _binRows(vo, rate, rOk) : _auctionRows(vo, rate, rOk),
          ),
        ],
      ),
    );
  }

  Widget _auctionRows(VehicleOptionEntity vo, double? rate, bool rOk) {
    final auctionUsd = vo.auctionPriceUsd ?? 0;
    final pct = (vo.buyersPremiumPct ?? 0) / 100.0;
    final fixed = vo.fixedPlatformFeesUsd ?? 0;
    final feesUsd = auctionUsd * pct + fixed;
    final totalUsd = auctionUsd + feesUsd;

    String ghs(double usd) => rOk ? CurrencyFormatter.formatGhs(usd * rate!) : _rateUnavailable();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _priceRow('Auction price', ghs(auctionUsd)),
        const SizedBox(height: 4),
        _priceRow(
          'Auction fees (est.)',
          ghs(feesUsd),
          subLabel: "Buyer's premium + Copart/IAAI fees",
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Divider(height: 0.5, thickness: 0.5, color: _kBorder),
        ),
        _totalRow('Est. total', ghs(totalUsd)),
        const SizedBox(height: 8),
        _amberDisclaimer(),
      ],
    );
  }

  Widget _binRows(VehicleOptionEntity vo, double? rate, bool rOk) {
    final binUsd = vo.buyItNowPriceUsd ?? vo.auctionPriceUsd ?? 0;
    final pct = (vo.buyersPremiumPct ?? 0) / 100.0;
    final fixed = vo.fixedPlatformFeesUsd ?? 0;
    final feesUsd = binUsd * pct + fixed;
    final totalUsd = binUsd + feesUsd;

    String ghs(double usd) => rOk ? CurrencyFormatter.formatGhs(usd * rate!) : _rateUnavailable();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _priceRow('Buy It Now price', ghs(binUsd)),
        const SizedBox(height: 4),
        _priceRow('Auction fees', ghs(feesUsd)),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Divider(height: 0.5, thickness: 0.5, color: _kBorder),
        ),
        _totalRow('Total', ghs(totalUsd)),
        const SizedBox(height: 8),
        _amberDisclaimer(),
      ],
    );
  }

  Widget _priceRow(String label, String amount, {String? subLabel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(fontSize: 12, color: _kTextSecondary),
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _kTextPrimary,
              ),
            ),
          ],
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            subLabel,
            style: GoogleFonts.dmSans(fontSize: 10, color: _kTextTertiary),
          ),
        ],
      ],
    );
  }

  Widget _totalRow(String label, String amount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _kSuccess,
          ),
        ),
      ],
    );
  }

  Widget _amberDisclaimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _kAmberBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 12, color: _kWarn),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                VehicleDetailConstants.finalBidDisclaimer,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: _kAmberText,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatLinkSection extends StatelessWidget {
  const _ChatLinkSection({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, thickness: 0.5, color: _kBorder),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () => context.push('/order/$orderId?tab=chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kPrimary,
                side: const BorderSide(color: _kPrimary, width: 0.5),
              ),
              child: Text(
                VehicleDetailConstants.chatWithAgentCta,
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleCardShimmer extends StatelessWidget {
  const _VehicleCardShimmer();

  @override
  Widget build(BuildContext context) {
    Widget shimmerBox(double h, {double? w, double r = 8}) {
      return Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: Colors.white,
        child: Container(
          height: h,
          width: w ?? double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          shimmerBox(180, r: 0),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmerBox(16, w: 200),
                const SizedBox(height: 8),
                shimmerBox(12, w: 160),
                const SizedBox(height: 8),
                Row(
                  children: [
                    shimmerBox(24, w: 72),
                    const SizedBox(width: 6),
                    shimmerBox(24, w: 88),
                  ],
                ),
                const SizedBox(height: 8),
                shimmerBox(14, w: double.infinity),
                const SizedBox(height: 8),
                shimmerBox(12, w: double.infinity),
                shimmerBox(12, w: double.infinity),
                shimmerBox(12, w: 160),
                const SizedBox(height: 12),
                shimmerBox(44, w: double.infinity, r: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
