import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../support/presentation/widgets/support_bottom_sheet.dart';
import '../../domain/entities/order_view.dart';
import 'agent_connection_assign_step.dart';
import 'agent_connection_labels.dart';

class AgentConnectionSearchingView extends StatefulWidget {
  const AgentConnectionSearchingView({
    super.key,
    required this.order,
    required this.pulseController,
    required this.showTakingLonger,
  });

  final OrderView order;
  final AnimationController pulseController;
  final bool showTakingLonger;

  @override
  State<AgentConnectionSearchingView> createState() =>
      _AgentConnectionSearchingViewState();
}

class _AgentConnectionSearchingViewState
    extends State<AgentConnectionSearchingView> {
  bool _showSupport = false;
  Timer? _supportTimer;

  @override
  void initState() {
    super.initState();
    _supportTimer = Timer(
      const Duration(minutes: 2),
      () {
        if (mounted) {
          setState(() => _showSupport = true);
        }
      },
    );
  }

  @override
  void dispose() {
    _supportTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.94, end: 1.06).animate(
                      CurvedAnimation(
                        parent: widget.pulseController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 3,
                        ),
                        color: AppColors.selectionTint,
                      ),
                      child: Icon(
                        Icons.search,
                        size: 44,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Finding your agent',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your preferences have been submitted.\n'
                    "We're assigning your dedicated agent now.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AgentConnectionAssignStep(
                          done: true,
                          active: false,
                          text: 'Preferences submitted',
                        ),
                        AgentConnectionAssignStep(
                          done: false,
                          active: true,
                          text: 'Assigning your agent',
                        ),
                        AgentConnectionAssignStep(
                          done: false,
                          active: false,
                          text: AgentConnectionLabels.step3Label(widget.order),
                        ),
                        AgentConnectionAssignStep(
                          done: false,
                          active: false,
                          text: AgentConnectionLabels.step4Label(widget.order),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: widget.showTakingLonger
                        ? Container(
                            key: const ValueKey('long'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.amberBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.warning),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 18,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Taking longer than expected. '
                                    "We'll notify you when assigned.",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.amberText,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            key: const ValueKey('short'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Usually takes a few minutes',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOut,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _showSupport
                        ? const _SupportPrompt(
                            key: ValueKey('support'),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('empty'),
                          ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportPrompt extends StatelessWidget {
  const _SupportPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Taking longer than expected?',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => SupportBottomSheet.show(context),
              icon: const Icon(
                Icons.headset_mic_rounded,
                size: 16,
                color: AppColors.secondary,
              ),
              label: Text(
                'Contact support',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(
                  color: AppColors.secondary,
                  width: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
