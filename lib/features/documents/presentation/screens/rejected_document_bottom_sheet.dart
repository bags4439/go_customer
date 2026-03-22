import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../../domain/entities/document_entity.dart';
import '../../core/constants/document_constants.dart';

class RejectedDocumentBottomSheet extends ConsumerWidget {
  final DocumentEntity document;
  final String orderId;

  const RejectedDocumentBottomSheet({
    super.key,
    required this.document,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0DFD8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _RejectedSheetContent(
              document: document,
              orderId: orderId,
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectedSheetContent extends StatefulWidget {
  final DocumentEntity document;
  final String orderId;

  const _RejectedSheetContent({
    required this.document,
    required this.orderId,
  });

  @override
  State<_RejectedSheetContent> createState() => _RejectedSheetContentState();
}

class _RejectedSheetContentState extends State<_RejectedSheetContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer(
        builder: (context, ref, _) {
          final agentName = ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ?? DocumentConstants.agent;
          final document = widget.document;
          final orderId = widget.orderId;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  DocumentConstants.documentRejected,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCEBEB),
                    border: Border(
                      left: BorderSide(color: const Color(0xFFE24B4A), width: 3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DocumentConstants.rejectionReason.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA32D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        document.rejectionReason ?? DocumentConstants.notApplicable,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: const Color(0xFFA32D2D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  DocumentConstants.whatToDoNext,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DocumentConstants.contactAgentHelp,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 44,
                  child: Material(
                    color: const Color(0xFF378ADD),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/order/$orderId?tab=chat');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Center(
                        child: Text(
                          '${DocumentConstants.askAgent} $agentName →',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/order/$orderId/documents/${document.id}');
                  },
                  child: Text(DocumentConstants.viewDocumentDetails),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
