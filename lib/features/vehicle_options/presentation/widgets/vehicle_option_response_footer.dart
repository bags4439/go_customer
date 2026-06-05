import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/buyer_vehicle_response.dart';
import '../../domain/entities/vehicle_option.dart';
import '../providers/vehicle_option_response_notifier.dart';

class VehicleOptionResponseFooter extends ConsumerWidget {
  const VehicleOptionResponseFooter({
    super.key,
    required this.option,
  });

  final VehicleOption option;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      vehicleOptionResponseNotifierProvider(option.id),
    );
    final notifier = ref.read(
      vehicleOptionResponseNotifierProvider(option.id).notifier,
    );
    final isSubmitting = status == VehicleOptionResponseStatus.submitting;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderSolid, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (notifier.lastError != null) ...[
            _ErrorBanner(
              message: notifier.lastError!,
              onDismiss: notifier.clearError,
            ),
            const SizedBox(height: 10),
          ],
          if (option.buyerResponse == BuyerVehicleResponse.pending)
            _PendingActions(
              isSubmitting: isSubmitting,
              onInterested: () => _submit(
                notifier,
                BuyerVehicleResponse.interested,
              ),
              onDecline: () => _submit(
                notifier,
                BuyerVehicleResponse.declined,
              ),
            )
          else
            _RespondedActions(
              response: option.buyerResponse,
              isSubmitting: isSubmitting,
              onUndo: () => _submit(
                notifier,
                BuyerVehicleResponse.pending,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submit(
    VehicleOptionResponseNotifier notifier,
    BuyerVehicleResponse response,
  ) async {
    await notifier.submit(
      vehicleOptionId: option.id,
      response: response,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.danger,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingActions extends StatelessWidget {
  const _PendingActions({
    required this.isSubmitting,
    required this.onInterested,
    required this.onDecline,
  });

  final bool isSubmitting;
  final VoidCallback onInterested;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Let your agent know if this option interests you. '
          'You can change your mind anytime.',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: isSubmitting ? null : onInterested,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'I am interested',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onDecline,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.borderSolid),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Not interested',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RespondedActions extends StatelessWidget {
  const _RespondedActions({
    required this.response,
    required this.isSubmitting,
    required this.onUndo,
  });

  final BuyerVehicleResponse response;
  final bool isSubmitting;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final isInterested = response == BuyerVehicleResponse.interested;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isInterested
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isInterested
                  ? AppColors.success.withValues(alpha: 0.25)
                  : AppColors.borderSolid,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isInterested
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                size: 18,
                color: isInterested ? AppColors.success : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isInterested
                      ? 'You marked this as interesting. Your agent has been notified.'
                      : 'You passed on this option. Your agent has been notified.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onUndo,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: const BorderSide(color: AppColors.secondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Change response',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
