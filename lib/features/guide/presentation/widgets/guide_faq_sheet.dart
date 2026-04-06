import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class GuideFaqItem {
  const GuideFaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}

/// All FAQ copy — never hardcode in UI.
const List<GuideFaqItem> kGuideFaqItems = [
  GuideFaqItem(
    question: 'Is my money safe?',
    answer:
        'Payments go directly to verified suppliers '
        'and shipping companies. Your agent never '
        'handles your money directly. You approve '
        'every payment before it leaves your account.',
  ),
  GuideFaqItem(
    question: 'What if I don\'t like the options?',
    answer:
        'You\'re never forced to accept a vehicle. '
        'Tell your agent what you want changed and '
        'they\'ll keep searching until you find '
        'the right one.',
  ),
  GuideFaqItem(
    question: 'How long does the process take?',
    answer:
        'Typically 6–10 weeks from your deposit to '
        'delivery at your door, depending on '
        'shipping schedules and port clearance. '
        'Your agent keeps you updated at every step.',
  ),
  GuideFaqItem(
    question: 'What if my bid is lost?',
    answer:
        'Your agent immediately starts searching '
        'for alternative options. Your deposit '
        'stays active and no additional payment '
        'is required.',
  ),
  GuideFaqItem(
    question: 'Can I cancel my order?',
    answer:
        'Yes — you can cancel for free before '
        'making your first payment. After payment, '
        'contact your agent to discuss your options.',
  ),
  GuideFaqItem(
    question: 'Who pays for repairs?',
    answer:
        'Your agent sends a detailed repair quote '
        'for your approval before any work begins. '
        'Nothing is done without your sign-off and '
        'the cost is agreed upfront.',
  ),
  GuideFaqItem(
    question: 'How does port clearance work?',
    answer:
        'Your agent handles all GRA paperwork, '
        'ICUMS submission, and duty payments on '
        'your behalf. You\'ll be notified at every '
        'stage and can track progress in the app.',
  ),
  GuideFaqItem(
    question: 'What happens after delivery?',
    answer:
        'You confirm receipt in the app and leave '
        'a quick rating for your agent. All your '
        'import documents are stored permanently '
        'in the Documents tab.',
  ),
];

class GuideFaqSheet extends StatefulWidget {
  const GuideFaqSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const GuideFaqSheet(),
    );
  }

  @override
  State<GuideFaqSheet> createState() => _GuideFaqSheetState();
}

class _GuideFaqSheetState extends State<GuideFaqSheet> {
  /// Index of the currently open item.
  /// -1 means all collapsed.
  int _openIndex = -1;

  void _toggle(int index) {
    setState(() {
      _openIndex = _openIndex == index ? -1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.borderSolid,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Help & FAQ',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Common questions answered.',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // FAQ accordion list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  itemCount: kGuideFaqItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    return _FaqAccordionTile(
                      item: kGuideFaqItems[i],
                      isOpen: _openIndex == i,
                      onTap: () => _toggle(i),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FaqAccordionTile extends StatefulWidget {
  const _FaqAccordionTile({
    required this.item,
    required this.isOpen,
    required this.onTap,
  });

  final GuideFaqItem item;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  State<_FaqAccordionTile> createState() => _FaqAccordionTileState();
}

class _FaqAccordionTileState extends State<_FaqAccordionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );
    if (widget.isOpen) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_FaqAccordionTile old) {
    super.didUpdateWidget(old);
    if (widget.isOpen != old.isOpen) {
      if (widget.isOpen) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSolid, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent strip — only visible
                  // when open, animates in with width
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOut,
                    width: widget.isOpen ? 3 : 0,
                    color: AppColors.secondary,
                  ),

                  // Content
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onTap,
                        splashColor: AppColors.secondary.withValues(
                          alpha: 0.06,
                        ),
                        highlightColor: AppColors.secondary.withValues(
                          alpha: 0.03,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Question row
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.item.question,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: widget.isOpen
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: AppColors.textPrimary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  AnimatedRotation(
                                    turns: widget.isOpen ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 240),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 20,
                                      color: widget.isOpen
                                          ? AppColors.secondary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),

                              // Answer — slides in
                              SizeTransition(
                                sizeFactor: _expandAnim,
                                axisAlignment: -1,
                                child: FadeTransition(
                                  opacity: _fadeAnim,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Divider(
                                        height: 1,
                                        color: AppColors.borderSolid,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        widget.item.answer,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          height: 1.65,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
