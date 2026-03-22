import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/styled_snackbar.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../core/constants/vehicle_detail_constants.dart';
import '../../domain/entities/max_bid_entity.dart';
import '../../domain/entities/vehicle_option_entity.dart';
import '../providers/vehicle_detail_providers.dart';

const _kBorderColor = 0xFFE0DFD8;
const _kSurface = 0xFFF5F4F0;
const _kPrimary = 0xFF378ADD;
const _kPrimaryText = 0xFF185FA5;
const _kSuccess = 0xFF1D9E75;
const _kSuccessText = 0xFF27500A;
const _kAmberBg = 0xFFFAEEDA;
const _kAmberBorder = 0xFFBA7517;
const _kAmberText = 0xFF633806;
const _kTextSecondary = 0xFF666666;
const _kTextTertiary = 0xFFAAAAAA;
const _kDisabledBg = 0xFFE0DFD8;
const _kConditionGreen = 0xFFEAF3DE;
const _kConditionGreenText = 0xFF27500A;
const _kConditionAmber = 0xFFFAEEDA;
const _kConditionAmberText = 0xFF633806;
const _kConditionRed = 0xFFFCEBEB;
const _kConditionRedText = 0xFFA32D2D;

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
    final optionAsync = ref.watch(vehicleOptionProvider(vehicleOptionId));
    final existingBidAsync = ref.watch(existingMaxBidProvider(vehicleOptionId));

    return optionAsync.when(
      data: (option) {
        if (option == null) {
          return _NotFoundState(orderId: orderId);
        }
        final isRejected = option.status == FirestoreEnumValues.vehicleOptionStatusRejected;
        final hasExistingBid = existingBidAsync.valueOrNull != null;
        if (isRejected) {
          return _RejectedLayout(
            orderId: orderId,
            vehicleOptionId: vehicleOptionId,
            option: option,
          );
        }
        if (hasExistingBid) {
          return _ConfirmedLayout(
            orderId: orderId,
            vehicleOptionId: vehicleOptionId,
            option: option,
            existingBid: existingBidAsync.value!,
          );
        }
        return _ActiveLayout(
          orderId: orderId,
          vehicleOptionId: vehicleOptionId,
          option: option,
        );
      },
      loading: () => _LoadingScaffold(orderId: orderId, vehicleOptionId: vehicleOptionId),
      error: (_, __) => _NotFoundState(orderId: orderId),
    );
  }
}

PreferredSizeWidget _buildAppBar(BuildContext context, String orderId, String? lotNumber) {
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
  final String vehicleOptionId;

  const _LoadingScaffold({required this.orderId, required this.vehicleOptionId});

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
                    child: Container(height: 24, width: 200, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(4))),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: AppColors.surface,
                    highlightColor: Colors.white,
                    child: Container(height: 16, width: 160, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(4))),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(3, (_) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Shimmer.fromColors(
                        baseColor: AppColors.surface,
                        highlightColor: Colors.white,
                        child: Container(height: 28, width: 80, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(20))),
                      ),
                    )),
                  ),
                  const SizedBox(height: 12),
                  Shimmer.fromColors(
                    baseColor: AppColors.surface,
                    highlightColor: Colors.white,
                    child: Container(height: 80, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 12),
                  Shimmer.fromColors(
                    baseColor: AppColors.surface,
                    highlightColor: Colors.white,
                    child: Container(height: 120, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12))),
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
                const Icon(Icons.directions_car_outlined, size: 48, color: Color(_kTextTertiary)),
                const SizedBox(height: 16),
                Text(
                  VehicleDetailConstants.vehicleNotFound,
                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  VehicleDetailConstants.vehicleNotFoundSub,
                  style: GoogleFonts.dmSans(fontSize: 13, color: const Color(_kTextSecondary)),
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

class _RejectedLayout extends StatelessWidget {
  final String orderId;
  final String vehicleOptionId;
  final VehicleOptionEntity option;

  const _RejectedLayout({
    required this.orderId,
    required this.vehicleOptionId,
    required this.option,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, orderId, option.lotNumber),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(_kAmberBg),
              border: const Border(left: BorderSide(color: Color(_kAmberBorder), width: 3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 20, color: Color(_kAmberBorder)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    VehicleDetailConstants.rejectedBanner,
                    style: GoogleFonts.dmSans(fontSize: 12, color: const Color(_kAmberText)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _VehicleContent(
              vehicleOptionId: vehicleOptionId,
              option: option,
              showMaxBidSection: false,
              showConfirmButton: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveLayout extends ConsumerStatefulWidget {
  final String orderId;
  final String vehicleOptionId;
  final VehicleOptionEntity option;

  const _ActiveLayout({
    required this.orderId,
    required this.vehicleOptionId,
    required this.option,
  });

  @override
  ConsumerState<_ActiveLayout> createState() => _ActiveLayoutState();
}

class _ActiveLayoutState extends ConsumerState<_ActiveLayout> {
  final ScrollController _scrollController = ScrollController();
  bool _isConfirming = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, widget.orderId, widget.option.lotNumber),
      body: _VehicleContent(
        vehicleOptionId: widget.vehicleOptionId,
        option: widget.option,
        showMaxBidSection: true,
        showConfirmButton: true,
        scrollController: _scrollController,
        isConfirming: _isConfirming,
        onConfirm: () async {
          final state = ref.read(maxBidInputNotifierProvider(widget.vehicleOptionId));
          if (state.parsedUsd == null || state.parsedUsd! <= 0) return;
          final userId = ref.read(authStateProvider).valueOrNull;
          if (userId == null) return;
          final rateModel = await ref.read(exchangeRateProvider.future);
          final rate = rateModel.usdToGhs;
          setState(() => _isConfirming = true);
          try {
            await ref.read(vehicleRepositoryProvider).confirmMaxBid(
                  orderId: widget.orderId,
                  vehicleOptionId: widget.vehicleOptionId,
                  buyerId: userId,
                  maxBidUsd: state.parsedUsd!,
                  maxBidGhs: state.parsedUsd! * rate,
                  exchangeRate: rate,
                );
            ref.invalidate(existingMaxBidProvider(widget.vehicleOptionId));
            ref.invalidate(vehicleOptionProvider(widget.vehicleOptionId));
            if (!mounted) return;
            setState(() => _isConfirming = false);
          } catch (e) {
            if (!mounted) return;
            setState(() => _isConfirming = false);
            if (!context.mounted) return;
            showErrorSnackBar(context, VehicleDetailConstants.couldNotConfirmBid);
          }
        },
      ),
    );
  }
}

class _ConfirmedLayout extends ConsumerWidget {
  final String orderId;
  final String vehicleOptionId;
  final VehicleOptionEntity option;
  final MaxBidEntity existingBid;

  const _ConfirmedLayout({
    required this.orderId,
    required this.vehicleOptionId,
    required this.option,
    required this.existingBid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(context, orderId, option.lotNumber),
      body: _VehicleContent(
        vehicleOptionId: vehicleOptionId,
        option: option,
        showMaxBidSection: true,
        showConfirmButton: false,
        isConfirmed: true,
        confirmedBidUsd: existingBid.maxBidUsd,
      ),
    );
  }
}

class _VehicleContent extends ConsumerStatefulWidget {
  final String vehicleOptionId;
  final VehicleOptionEntity option;
  final bool showMaxBidSection;
  final bool showConfirmButton;
  final ScrollController? scrollController;
  final bool isConfirming;
  final VoidCallback? onConfirm;
  final bool isConfirmed;
  final double? confirmedBidUsd;

  const _VehicleContent({
    required this.vehicleOptionId,
    required this.option,
    required this.showMaxBidSection,
    required this.showConfirmButton,
    this.scrollController,
    this.isConfirming = false,
    this.onConfirm,
    this.isConfirmed = false,
    this.confirmedBidUsd,
  });

  @override
  ConsumerState<_VehicleContent> createState() => _VehicleContentState();
}

class _VehicleContentState extends ConsumerState<_VehicleContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  bool _costExpanded = false;
  final _pageController = PageController();
  int _photoIndex = 0;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _photoUrls =>
      widget.option.photoUrls.isNotEmpty
          ? widget.option.photoUrls
          : (widget.option.photoUrl != null ? [widget.option.photoUrl!] : []);

  @override
  Widget build(BuildContext context) {
    final hasPhotos = _photoUrls.isNotEmpty;
    final rateAsync = ref.watch(exchangeRateProvider);
    final inputState = ref.watch(maxBidInputNotifierProvider(widget.vehicleOptionId));
    final agentAsync = ref.watch(agentForVehicleProvider(widget.vehicleOptionId));

    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasPhotos)
            _PhotoGallery(
              vehicleOptionId: widget.vehicleOptionId,
              urls: _photoUrls,
              pageController: _pageController,
              currentIndex: _photoIndex,
              onPageChanged: (i) => setState(() => _photoIndex = i),
            )
          else
            _PhotoPlaceholder(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: 4),
                _buildSubtitle(),
                const SizedBox(height: 12),
                _SpecsPills(option: widget.option),
                const SizedBox(height: 16),
                _DamageCard(description: widget.option.damageDescription),
                if (widget.option.agentNote != null && widget.option.agentNote!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _AgentNote(agentAsync: agentAsync, note: widget.option.agentNote!),
                ],
                const SizedBox(height: 12),
                _CostSummaryCard(
                  vehicleOptionId: widget.vehicleOptionId,
                  option: widget.option,
                  rate: rateAsync.valueOrNull?.usdToGhs,
                  expanded: _costExpanded,
                  onToggle: () => setState(() => _costExpanded = !_costExpanded),
                ),
                if (showMaxBidSection) ...[
                  const SizedBox(height: 14),
                  _MaxBidSection(
                    vehicleOptionId: widget.vehicleOptionId,
                    option: widget.option,
                    rate: rateAsync.valueOrNull?.usdToGhs,
                    isConfirmed: widget.isConfirmed,
                    confirmedBidUsd: widget.confirmedBidUsd,
                  ),
                ],
                if (widget.showConfirmButton) ...[
                  const SizedBox(height: 4),
                  _ConfirmButton(
                    inputState: inputState,
                    isConfirming: widget.isConfirming,
                    onConfirm: widget.onConfirm,
                  ),
                ],
                if (widget.isConfirmed) ...[
                  const SizedBox(height: 12),
                  _ConfirmedBanner(option: widget.option, agentAsync: agentAsync),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get showMaxBidSection => widget.showMaxBidSection;

  Widget _buildTitle() {
    final parts = <String>[];
    if (widget.option.year != null) parts.add('${widget.option.year}');
    parts.add(widget.option.make ?? '');
    parts.add(widget.option.model ?? '');
    if (widget.option.trim != null && widget.option.trim!.isNotEmpty) parts.add(widget.option.trim!);
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
    final parts = [source, if (loc.isNotEmpty) loc, if (date.isNotEmpty) '${VehicleDetailConstants.auctionLabel}: $date'];
    return Text(
      parts.join(' · '),
      style: GoogleFonts.dmSans(fontSize: 13, color: const Color(_kTextSecondary)),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_car_outlined, size: 48, color: Color(_kTextTertiary)),
                          const SizedBox(height: 8),
                          Text(
                            VehicleDetailConstants.photoNotAvailable,
                            style: GoogleFonts.dmSans(fontSize: 11, color: const Color(_kTextTertiary)),
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
                    color: active ? const Color(_kPrimary) : const Color(_kBorderColor),
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
                child: const SizedBox(width: 44, height: 44, child: Icon(Icons.close, color: Colors.white, size: 24)),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      color: const Color(_kSurface),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_outlined, size: 48, color: Color(_kTextTertiary)),
          const SizedBox(height: 8),
          Text(
            VehicleDetailConstants.photoNotAvailable,
            style: GoogleFonts.dmSans(fontSize: 11, color: const Color(_kTextTertiary)),
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
      } else if (option.condition == FirestoreEnumValues.vehicleConditionRepairable) {
        bg = const Color(_kConditionAmber);
        text = const Color(_kConditionAmberText);
      } else if (option.condition == FirestoreEnumValues.vehicleConditionFullRebuild) {
        bg = const Color(_kConditionRed);
        text = const Color(_kConditionRedText);
      }
      pills.add(_Pill(text: option.conditionLabel!, backgroundColor: bg, textColor: text));
    }
    if (option.mileage != null) {
      final formatted = NumberFormat('#,###').format(option.mileage);
      pills.add(_Pill(text: '$formatted mi'));
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
        children: List.generate(pills.length, (i) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: pills[i],
        )),
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

class _DamageCard extends StatelessWidget {
  final String? description;

  const _DamageCard({this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(_kSurface),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
          const SizedBox(height: 6),
          Text(
            description != null && description!.isNotEmpty
                ? description!
                : VehicleDetailConstants.noDamageDescription,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: description != null && description!.isNotEmpty
                  ? const Color(_kTextSecondary)
                  : const Color(_kTextTertiary),
              fontStyle: description == null || description!.isEmpty ? FontStyle.italic : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentNote extends StatelessWidget {
  final AsyncValue<AgentForVehicleView?> agentAsync;
  final String note;

  const _AgentNote({required this.agentAsync, required this.note});

  @override
  Widget build(BuildContext context) {
    final agent = agentAsync.valueOrNull;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFE6F1FB),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            agent?.initials ?? 'AG',
            style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(_kPrimaryText)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${agent?.firstName ?? 'Agent'}${VehicleDetailConstants.agentNoteSuffix}",
                style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(_kPrimaryText)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  style: GoogleFonts.dmSans(fontSize: 13, color: const Color(_kTextSecondary), height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CostSummaryCard extends ConsumerWidget {
  final String vehicleOptionId;
  final VehicleOptionEntity option;
  final double? rate;
  final bool expanded;
  final VoidCallback onToggle;

  const _CostSummaryCard({
    required this.vehicleOptionId,
    required this.option,
    required this.rate,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveCost = ref.watch(liveCostProvider(vehicleOptionId));
    final totalGhs = liveCost?.totalGhs ?? 0.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(_kBorderColor), width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          VehicleDetailConstants.estimatedTotalLanded,
                          style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(_kTextSecondary)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rate != null ? CurrencyFormatter.formatGhs(totalGhs) : VehicleDetailConstants.rateUnavailable,
                          style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(_kSuccess)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    expanded ? VehicleDetailConstants.hideBreakdown : VehicleDetailConstants.seeBreakdown,
                    style: GoogleFonts.dmSans(fontSize: 12, color: const Color(_kPrimaryText)),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.chevron_right, size: 16, color: Color(_kPrimaryText)),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: expanded && liveCost != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
                    child: Column(
                      children: [
                        Container(height: 0.5, color: const Color(_kBorderColor)),
                        const SizedBox(height: 10),
                        ...liveCost.allLineItems.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: GoogleFonts.dmSans(fontSize: 12, color: const Color(_kTextSecondary)),
                                ),
                              ),
                              if (item.usdText != null)
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    item.usdText!,
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.dmSans(
                                      fontSize: item.isTotal ? 13 : 12,
                                      fontWeight: item.isTotal ? FontWeight.w600 : FontWeight.w500,
                                      color: item.isDeduction ? const Color(_kSuccess) : null,
                                    ),
                                  ),
                                ),
                              if (item.ghsText != null) ...[
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    item.ghsText!,
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.dmSans(
                                      fontSize: item.isTotal ? 13 : 11,
                                      fontWeight: item.isTotal ? FontWeight.w600 : FontWeight.w400,
                                      color: item.isDeduction ? const Color(_kSuccess) : const Color(_kTextSecondary),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )),
                        const SizedBox(height: 6),
                        Text(
                          '${VehicleDetailConstants.atRateNote}${rate?.toStringAsFixed(2) ?? '—'}',
                          style: GoogleFonts.dmSans(fontSize: 10, color: const Color(_kTextTertiary)),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _MaxBidSection extends ConsumerStatefulWidget {
  final String vehicleOptionId;
  final VehicleOptionEntity option;
  final double? rate;
  final bool isConfirmed;
  final double? confirmedBidUsd;

  const _MaxBidSection({
    required this.vehicleOptionId,
    required this.option,
    required this.rate,
    required this.isConfirmed,
    this.confirmedBidUsd,
  });

  @override
  ConsumerState<_MaxBidSection> createState() => _MaxBidSectionState();
}

class _MaxBidSectionState extends ConsumerState<_MaxBidSection> {
  late TextEditingController _controller;
  bool _synced = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_synced) {
      if (widget.isConfirmed && widget.confirmedBidUsd != null) {
        _controller.text = widget.confirmedBidUsd!.toStringAsFixed(0);
      } else {
        final state = ref.read(maxBidInputNotifierProvider(widget.vehicleOptionId));
        _controller.text = state.rawInput;
      }
      _synced = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputState = ref.watch(maxBidInputNotifierProvider(widget.vehicleOptionId));
    final liveCost = ref.watch(liveCostProvider(widget.vehicleOptionId));
    final agentAsync = ref.watch(agentForVehicleProvider(widget.vehicleOptionId));
    final agentName = agentAsync.valueOrNull?.firstName ?? 'Your agent';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(_kSurface),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            VehicleDetailConstants.setMaxBid,
            style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            VehicleDetailConstants.setMaxBidSub,
            style: GoogleFonts.dmSans(fontSize: 12, color: const Color(_kTextSecondary), height: 1.5),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('USD \$', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(_kTextSecondary))),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  readOnly: widget.isConfirmed,
                  style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w400, color: const Color(_kBorderColor)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(_kBorderColor))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(_kPrimary), width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  onChanged: (v) => ref.read(maxBidInputNotifierProvider(widget.vehicleOptionId).notifier).setRawInput(v),
                ),
              ),
            ],
          ),
          if (liveCost != null && liveCost.ghsConversionText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                liveCost.ghsConversionText,
                style: GoogleFonts.dmSans(fontSize: 12, color: const Color(_kTextSecondary)),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (widget.option.auctionPriceUsd != null && inputState.parsedUsd != null && inputState.parsedUsd! > 0)
            _ImpactMessage(option: widget.option, inputState: inputState, agentName: agentName),
          const SizedBox(height: 12),
          Row(
            children: [3800.0, 4200.0, 4500.0, 5000.0].map((preset) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _PresetButton(
                  value: preset,
                  selected: (inputState.parsedUsd ?? 0) == preset,
                  onTap: widget.isConfirmed ? null : () {
                    ref.read(maxBidInputNotifierProvider(widget.vehicleOptionId).notifier).setPreset(preset);
                    _controller.text = preset.toStringAsFixed(0);
                  },
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _ImpactMessage extends StatelessWidget {
  final VehicleOptionEntity option;
  final MaxBidInputState inputState;
  final String agentName;

  const _ImpactMessage({required this.option, required this.inputState, required this.agentName});

  @override
  Widget build(BuildContext context) {
    final bid = inputState.parsedUsd ?? 0;
    final auction = option.auctionPriceUsd ?? 0;
    if (bid < auction * 0.9) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(_kAmberBg),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: Color(_kAmberBorder)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                VehicleDetailConstants.impactLow
                    .replaceAll('[usd]', CurrencyFormatter.formatUsd(auction))
                    .replaceAll('[agent]', agentName),
                style: GoogleFonts.dmSans(fontSize: 11, color: const Color(_kAmberText), height: 1.4),
              ),
            ),
          ],
        ),
      );
    }
    if (bid <= auction * 1.2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(_kConditionGreen),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 14, color: Color(_kSuccess)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                VehicleDetailConstants.impactGood.replaceAll('[agent]', agentName),
                style: GoogleFonts.dmSans(fontSize: 11, color: const Color(_kSuccessText), height: 1.4),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(_kConditionGreen),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: Color(_kSuccess)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              VehicleDetailConstants.impactStrong,
              style: GoogleFonts.dmSans(fontSize: 11, color: const Color(_kSuccessText), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final double value;
  final bool selected;
  final VoidCallback? onTap;

  const _PresetButton({required this.value, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE6F1FB) : Colors.transparent,
            border: Border.all(
              color: selected ? const Color(_kPrimary) : const Color(_kBorderColor),
              width: selected ? 1.5 : 0.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '\$${value.toStringAsFixed(0)}',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? const Color(_kPrimaryText) : const Color(_kTextSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final MaxBidInputState inputState;
  final bool isConfirming;
  final VoidCallback? onConfirm;

  const _ConfirmButton({
    required this.inputState,
    required this.isConfirming,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = inputState.isValid && !isConfirming;
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onConfirm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? const Color(_kPrimary) : const Color(_kDisabledBg),
          foregroundColor: enabled ? Colors.white : const Color(_kTextTertiary),
          disabledBackgroundColor: const Color(_kDisabledBg),
          disabledForegroundColor: const Color(_kTextTertiary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isConfirming
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                enabled ? VehicleDetailConstants.confirmMaxBidCta : VehicleDetailConstants.enterBidToContinue,
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

class _ConfirmedBanner extends StatelessWidget {
  final VehicleOptionEntity option;
  final AsyncValue<AgentForVehicleView?> agentAsync;

  const _ConfirmedBanner({required this.option, required this.agentAsync});

  @override
  Widget build(BuildContext context) {
    final agentName = agentAsync.valueOrNull?.firstName ?? 'Your agent';
    final dateStr = option.auctionDate != null
        ? DateFormat('d MMM yyyy').format(option.auctionDate!)
        : '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(_kSuccess),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  VehicleDetailConstants.maxBidConfirmed,
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 3),
                Text(
                  VehicleDetailConstants.maxBidConfirmedSub
                      .replaceAll('[agent]', agentName)
                      .replaceAll('[date]', dateStr),
                  style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
