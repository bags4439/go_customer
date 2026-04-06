import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/currency_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../core/constants/vehicle_detail_constants.dart';
import '../../domain/entities/vehicle_option_entity.dart';
import '../providers/vehicle_detail_providers.dart';
import '../widgets/agent_vehicle_avatar.dart';

const _kBorderColor = 0xFFE0DFD8;
const _kSurface = 0xFFF5F4F0;
const _kPrimary = 0xFF378ADD;
const _kPrimaryText = 0xFF185FA5;
const _kSuccess = 0xFF1D9E75;
const _kAmberBg = 0xFFFAEEDA;
const _kAmberBorder = 0xFFBA7517;
const _kAmberText = 0xFF633806;
const _kTextSecondary = 0xFF666666;
const _kTextTertiary = 0xFFAAAAAA;
const _kConditionGreen = 0xFFEAF3DE;
const _kConditionGreenText = 0xFF27500A;
const _kConditionAmber = 0xFFFAEEDA;
const _kConditionAmberText = 0xFF633806;
const _kConditionRed = 0xFFFCEBEB;
const _kConditionRedText = 0xFFA32D2D;
const _kBinPillBg = 0xFFE6F1FB;
const _kBinPillFg = 0xFF185FA5;

class VehicleDetailScreen extends ConsumerWidget {
  final String orderId;
  final String vehicleOptionId;

  const VehicleDetailScreen({
    super.key,
    required this.orderId,
    required this.vehicleOptionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionAsync = ref.watch(vehicleOptionStreamProvider(vehicleOptionId));

    return optionAsync.when(
      data: (option) {
        if (option == null) {
          return _NotFoundState(orderId: orderId);
        }
        final isRejected =
            option.status == FirestoreEnumValues.vehicleOptionStatusRejected;
        return _VehicleDetailScaffold(
          orderId: orderId,
          vehicleOptionId: vehicleOptionId,
          option: option,
          showRejectedBanner: isRejected,
        );
      },
      loading: () => _LoadingScaffold(orderId: orderId),
      error: (_, __) => _NotFoundState(orderId: orderId),
    );
  }
}

PreferredSizeWidget _buildAppBar(
  BuildContext context,
  String orderId,
  String? lotNumber,
) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => context.pop(),
    ),
    title: Text(
      VehicleDetailConstants.screenTitle,
      style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600),
    ),
    elevation: 0,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    actions: [
      if (lotNumber != null && lotNumber.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(_kSurface),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${VehicleDetailConstants.lotPillPrefix}$lotNumber',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(_kTextSecondary),
              ),
            ),
          ),
        )
      else
        const SizedBox.shrink(),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(0.5),
      child: Container(color: const Color(_kBorderColor), height: 0.5),
    ),
  );
}

class _LoadingScaffold extends StatelessWidget {
  final String orderId;

  const _LoadingScaffold({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, orderId, null),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Shimmer.fromColors(
              baseColor: AppColors.surface,
              highlightColor: Colors.white,
              child: Container(height: 220, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: AppColors.surface,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 24,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: AppColors.surface,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 16,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  final String orderId;

  const _NotFoundState({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, orderId, null),
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
                const Icon(
                  Icons.directions_car_outlined,
                  size: 48,
                  color: Color(_kTextTertiary),
                ),
                const SizedBox(height: 16),
                Text(
                  VehicleDetailConstants.vehicleNotFound,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  VehicleDetailConstants.vehicleNotFoundSub,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(_kTextSecondary),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(_kPrimary),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(VehicleDetailConstants.backToChat),
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

class _VehicleDetailScaffold extends ConsumerStatefulWidget {
  final String orderId;
  final String vehicleOptionId;
  final VehicleOptionEntity option;
  final bool showRejectedBanner;

  const _VehicleDetailScaffold({
    required this.orderId,
    required this.vehicleOptionId,
    required this.option,
    required this.showRejectedBanner,
  });

  @override
  ConsumerState<_VehicleDetailScaffold> createState() =>
      _VehicleDetailScaffoldState();
}

class _VehicleDetailScaffoldState
    extends ConsumerState<_VehicleDetailScaffold> {
  final PageController _pageController = PageController();
  int _photoIndex = 0;
  bool _damageExpanded = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _photoUrls => widget.option.photoUrls.isNotEmpty
      ? widget.option.photoUrls
      : (widget.option.photoUrl != null ? [widget.option.photoUrl!] : []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, widget.orderId, widget.option.lotNumber),
      body: Column(
        children: [
          if (widget.showRejectedBanner) _RejectedBanner(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_photoUrls.isNotEmpty)
                    _PhotoGallery(
                      vehicleOptionId: widget.vehicleOptionId,
                      urls: _photoUrls,
                      pageController: _pageController,
                      currentIndex: _photoIndex,
                      onPageChanged: (i) => setState(() => _photoIndex = i),
                    )
                  else
                    const _PhotoPlaceholder(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        const SizedBox(height: 4),
                        _buildSubtitle(),
                        const SizedBox(height: 12),
                        _SpecsPills(option: widget.option),
                        const SizedBox(height: 16),
                        _DamageBlock(
                          option: widget.option,
                          expanded: _damageExpanded,
                          onToggle: () => setState(
                            () => _damageExpanded = !_damageExpanded,
                          ),
                        ),
                        if (widget.option.agentNote != null &&
                            widget.option.agentNote!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _AgentNote(
                            vehicleOptionId: widget.vehicleOptionId,
                            note: widget.option.agentNote!,
                          ),
                        ],
                        const SizedBox(height: 12),
                        _ReadOnlyCostCard(
                          vehicleOptionId: widget.vehicleOptionId,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(_kPrimary),
                              side: const BorderSide(
                                color: Color(_kPrimary),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              VehicleDetailConstants.chatWithAgentCta,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    final parts = <String>[];
    if (widget.option.year != null) parts.add('${widget.option.year}');
    parts.add(widget.option.make ?? '');
    parts.add(widget.option.model ?? '');
    if (widget.option.trim != null && widget.option.trim!.isNotEmpty) {
      parts.add(widget.option.trim!);
    }
    final title = parts.where((e) => e.isNotEmpty).join(' ');
    return Text(
      title.isEmpty ? 'Vehicle' : title,
      style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSubtitle() {
    final source = widget.option.source == FirestoreEnumValues.vehicleSourceIaa
        ? VehicleDetailConstants.sourceIaa
        : VehicleDetailConstants.sourceCopart;
    final loc = widget.option.auctionLocation ?? '';
    final date = widget.option.auctionDate != null
        ? DateFormat('d MMM yyyy').format(widget.option.auctionDate!)
        : '';
    final parts = <String>[
      source,
      if (loc.isNotEmpty) loc,
      if (date.isNotEmpty && !widget.option.isBuyItNow)
        '${VehicleDetailConstants.auctionLabel}: $date',
    ];
    return Text(
      parts.join(' · '),
      style: GoogleFonts.dmSans(
        fontSize: 13,
        color: const Color(_kTextSecondary),
      ),
    );
  }
}

class _RejectedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(_kAmberBg),
        border: const Border(
          left: BorderSide(color: Color(_kAmberBorder), width: 3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: Color(_kAmberBorder),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              VehicleDetailConstants.rejectedBanner,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(_kAmberText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  final String vehicleOptionId;
  final List<String> urls;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _PhotoGallery({
    required this.vehicleOptionId,
    required this.urls,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: pageController,
            itemCount: urls.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openFullScreen(context, index),
                child: Hero(
                  tag: 'vehicle_photo_${vehicleOptionId}_$index',
                  child: CachedNetworkImage(
                    imageUrl: urls[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 220,
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: AppColors.surface,
                      highlightColor: Colors.white,
                      child: Container(color: Colors.grey, height: 220),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(_kSurface),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car_outlined,
                            size: 48,
                            color: Color(_kTextTertiary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (urls.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(urls.length, (i) {
              final active = i == currentIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: active ? 8 : 6,
                  height: active ? 8 : 6,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(_kPrimary)
                        : const Color(_kBorderColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  void _openFullScreen(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => _FullScreenGallery(
          vehicleOptionId: vehicleOptionId,
          urls: urls,
          initialIndex: index,
        ),
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final String vehicleOptionId;
  final List<String> urls;
  final int initialIndex;

  const _FullScreenGallery({
    required this.vehicleOptionId,
    required this.urls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    _index = widget.initialIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.urls[i],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Material(
              color: Colors.black45,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_index + 1} / ${widget.urls.length}',
                  style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      color: const Color(_kSurface),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car_outlined,
            size: 48,
            color: Color(_kTextTertiary),
          ),
          const SizedBox(height: 8),
          Text(
            VehicleDetailConstants.photoNotAvailable,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: const Color(_kTextTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecsPills extends StatelessWidget {
  final VehicleOptionEntity option;

  const _SpecsPills({required this.option});

  @override
  Widget build(BuildContext context) {
    final pills = <Widget>[];
    if (option.conditionLabel != null && option.conditionLabel!.isNotEmpty) {
      Color bg = const Color(_kSurface);
      Color text = const Color(_kTextSecondary);
      if (option.condition == FirestoreEnumValues.vehicleConditionRunAndDrive) {
        bg = const Color(_kConditionGreen);
        text = const Color(_kConditionGreenText);
      } else if (option.condition ==
          FirestoreEnumValues.vehicleConditionRepairable) {
        bg = const Color(_kConditionAmber);
        text = const Color(_kConditionAmberText);
      } else if (option.condition ==
          FirestoreEnumValues.vehicleConditionFullRebuild) {
        bg = const Color(_kConditionRed);
        text = const Color(_kConditionRedText);
      }
      pills.add(
        _Pill(
          text: option.conditionLabel!,
          backgroundColor: bg,
          textColor: text,
        ),
      );
    }
    if (option.mileage != null) {
      final formatted = NumberFormat('#,###').format(option.mileage);
      pills.add(_Pill(text: '$formatted mi'));
    }
    if (option.isBuyItNow) {
      pills.add(
        _Pill(
          text: 'Buy It Now',
          backgroundColor: const Color(_kBinPillBg),
          textColor: const Color(_kBinPillFg),
        ),
      );
    }
    if (option.transmission != null && option.transmission!.isNotEmpty) {
      final t = option.transmission!.toLowerCase();
      pills.add(_Pill(text: t.contains('auto') ? 'Automatic' : 'Manual'));
    }
    if (option.engine != null && option.engine!.isNotEmpty) {
      pills.add(_Pill(text: option.engine!));
    }
    if (option.colour != null && option.colour!.isNotEmpty) {
      pills.add(_Pill(text: option.colour!));
    }
    if (pills.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          pills.length,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: pills[i],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const _Pill({required this.text, this.backgroundColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(_kSurface),
        border: Border.all(color: const Color(_kBorderColor), width: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor ?? const Color(_kTextSecondary),
        ),
      ),
    );
  }
}

class _DamageBlock extends StatelessWidget {
  final VehicleOptionEntity option;
  final bool expanded;
  final VoidCallback onToggle;

  const _DamageBlock({
    required this.option,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final desc = option.damageDescription?.trim() ?? '';
    if (!option.hasVehicleDamage) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 14,
            color: Color(_kSuccess),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                'Clean vehicle — no significant damage',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(_kSuccess),
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (desc.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          VehicleDetailConstants.damageDescriptionLabel.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(_kTextTertiary),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(_kSurface),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  maxLines: expanded ? null : 3,
                  overflow: expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(_kTextSecondary),
                    height: 1.5,
                  ),
                ),
                if (desc.length > 120 && !expanded)
                  GestureDetector(
                    onTap: onToggle,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Show more →',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(_kPrimaryText),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AgentNote extends ConsumerWidget {
  final String vehicleOptionId;
  final String note;

  const _AgentNote({required this.vehicleOptionId, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentForVehicleProvider(vehicleOptionId));
    final agent = agentAsync.valueOrNull;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (agent != null)
          AgentVehicleAvatar(
            agent: agent,
            radius: 16,
            heroTag:
                'agent_avatar_${agent.agentId}_vehicle_$vehicleOptionId',
          )
        else
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F1FB),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'AG',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(_kPrimaryText),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${agent?.firstName ?? 'Agent'}${VehicleDetailConstants.agentNoteSuffix}",
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(_kPrimaryText),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: Color(_kSurface),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  note,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(_kTextSecondary),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyCostCard extends ConsumerWidget {
  final String vehicleOptionId;

  const _ReadOnlyCostCard({required this.vehicleOptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cost = ref.watch(readOnlyVehicleCostProvider(vehicleOptionId));
    final option = ref
        .watch(vehicleOptionStreamProvider(vehicleOptionId))
        .valueOrNull;
    final currency = ref.watch(preferredCurrencyProvider);

    if (option == null || cost == null || cost.listPriceUsd == null) {
      return const SizedBox.shrink();
    }

    final list = cost.listPriceUsd!;
    final pctLabel = (option.buyersPremiumPct ?? 0).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(_kBorderColor), width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _currencyRow(
            cost.isBuyItNow
                ? 'Buy It Now price'
                : VehicleDetailConstants.auctionPriceLabel,
            list,
            currency,
          ),
          const SizedBox(height: 10),
          _currencyRow(
            '${VehicleDetailConstants.buyersPremium} ($pctLabel%)',
            cost.premiumUsd,
            currency,
          ),
          const SizedBox(height: 10),
          _currencyRow(
            VehicleDetailConstants.copartIaaFees,
            cost.fixedFeesUsd,
            currency,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: Color(_kBorderColor),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  VehicleDetailConstants.estTotalLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(
                      cost.totalUsd * currency.usdToRate,
                      currency,
                    ),
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(_kSuccess),
                    ),
                  ),
                  if (currency.code != 'USD') ...[
                    const SizedBox(height: 2),
                    Text(
                      '≈ ${CurrencyFormatter.formatUsd(cost.totalUsd)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(_kTextTertiary),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(_kAmberBg),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Color(_kAmberBorder),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      VehicleDetailConstants.finalBidDisclaimer,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: const Color(_kAmberText),
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencyRow(
    String label,
    double usdAmount,
    CurrencyModel currency,
  ) {
    final converted = usdAmount * currency.usdToRate;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(_kTextSecondary),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(converted, currency),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (currency.code != 'USD')
              Text(
                '≈ ${CurrencyFormatter.formatUsd(usdAmount)}',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(_kTextTertiary),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
