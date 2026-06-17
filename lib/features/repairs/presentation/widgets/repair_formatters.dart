import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../core/constants/repair_constants.dart';
import '../../domain/entities/repair_job.dart';

final repairDisplayDateFormat = DateFormat('d MMM yyyy');

/// Formats a GHS-stored repair_jobs amount for display.
CurrencyDisplay repairFormatGhs(double? amountGhs, CurrencyModel currency) {
  if (amountGhs == null) {
    return const CurrencyDisplay(primary: '—');
  }
  return CurrencyFormatter.formatGhsForDisplay(
    amountGhs: amountGhs,
    preferredCurrency: currency,
  );
}

/// Primary + optional secondary USD line for GHS-stored amounts.
class RepairGhsAmountColumn extends StatelessWidget {
  const RepairGhsAmountColumn({
    super.key,
    required this.amountGhs,
    required this.currency,
    this.primaryStyle,
    this.align = CrossAxisAlignment.end,
  });

  final double? amountGhs;
  final CurrencyModel currency;
  final TextStyle? primaryStyle;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    final display = repairFormatGhs(amountGhs, currency);
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          display.primary,
          style: primaryStyle ?? AppTextStyles.cardLabel,
        ),
        if (display.hasSecondary) ...[
          const SizedBox(height: 2),
          Text(
            display.secondary!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Nested garage-invoice breakdown (Option A) with platform fee and total.
class RepairQuotePricingSection extends StatelessWidget {
  const RepairQuotePricingSection({
    super.key,
    required this.job,
    required this.currency,
    this.showPaymentSplit = true,
    this.showPaymentTiming = true,
    this.showTotalFooter = true,
    this.totalLabel = RepairConstants.totalYouPayLabel,
    this.totalSubLabel = RepairConstants.totalYouPaySub,
    this.totalAmountGhs,
  });

  final RepairJob job;
  final CurrencyModel currency;
  final bool showPaymentSplit;
  final bool showPaymentTiming;
  final bool showTotalFooter;
  final String totalLabel;
  final String? totalSubLabel;
  final double? totalAmountGhs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepairQuoteBreakdown(
          job: job,
          currency: currency,
          showPaymentSplit: showPaymentSplit,
          showPaymentTiming: showPaymentTiming,
        ),
        if (showTotalFooter) ...[
          const SizedBox(height: 16),
          RepairQuoteTotalFooter(
            label: totalLabel,
            subLabel: totalSubLabel,
            amountGhs: totalAmountGhs ?? job.totalQuotedGhs,
            currency: currency,
          ),
        ],
      ],
    );
  }
}

/// Garage invoice with nested parts deposit + workmanship sub-rows.
class RepairQuoteBreakdown extends StatelessWidget {
  const RepairQuoteBreakdown({
    super.key,
    required this.job,
    required this.currency,
    this.showPaymentSplit = true,
    this.showPaymentTiming = true,
  });

  final RepairJob job;
  final CurrencyModel currency;
  final bool showPaymentSplit;
  final bool showPaymentTiming;

  @override
  Widget build(BuildContext context) {
    final invoice = job.effectiveInvoiceGhs;
    final platformFee = job.effectivePlatformFeeGhs;
    final partsDeposit = job.partsDepositGhs;
    final workmanship = job.effectiveWorkmanshipGhs;
    final showSplit =
        showPaymentSplit && partsDeposit != null && workmanship != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (invoice != null) ...[
          Text(
            RepairConstants.garageCostsSectionLabel,
            style: AppTextStyles.sectionLabel.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          _GarageInvoiceBlock(
            invoiceGhs: invoice,
            partsDepositGhs: showSplit ? partsDeposit : null,
            workmanshipGhs: showSplit ? workmanship : null,
            currency: currency,
            showPaymentTiming: showPaymentTiming,
          ),
        ],
        if (platformFee != null) ...[
          const SizedBox(height: 14),
          Text(
            RepairConstants.platformFeeSectionLabel,
            style: AppTextStyles.sectionLabel.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppColors.borderSolid),
            ),
            child: _BreakdownRow(
              label: RepairConstants.platformServiceFeeLabel,
              subLabel: RepairConstants.platformServiceFeeSub,
              amountGhs: platformFee,
              currency: currency,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GarageInvoiceBlock extends StatelessWidget {
  const _GarageInvoiceBlock({
    required this.invoiceGhs,
    required this.currency,
    this.partsDepositGhs,
    this.workmanshipGhs,
    this.showPaymentTiming = true,
  });

  final double invoiceGhs;
  final double? partsDepositGhs;
  final double? workmanshipGhs;
  final CurrencyModel currency;
  final bool showPaymentTiming;

  @override
  Widget build(BuildContext context) {
    final hasSplit = partsDepositGhs != null && workmanshipGhs != null;
    final partsDisplay = hasSplit
        ? repairFormatGhs(partsDepositGhs, currency).primary
        : null;
    final workmanshipDisplay = hasSplit
        ? repairFormatGhs(workmanshipGhs, currency).primary
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.borderSolid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.selectionTint.withValues(alpha: 0.45),
              borderRadius: hasSplit
                  ? const BorderRadius.vertical(top: Radius.circular(11))
                  : BorderRadius.circular(AppTheme.radiusLg),
              border: hasSplit
                  ? const Border(
                      bottom: BorderSide(color: AppColors.borderSolid),
                    )
                  : null,
            ),
            child: _BreakdownRow(
              label: RepairConstants.garageInvoiceLabel,
              amountGhs: invoiceGhs,
              currency: currency,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              amountStyle: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (hasSplit) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Text(
                RepairConstants.invoiceSplitHint,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 14, 8),
              child: Column(
                children: [
                  _NestedSplitRow(
                    label: RepairConstants.partsDepositLabel,
                    timing: showPaymentTiming
                        ? RepairConstants.partsDepositTiming
                        : null,
                    amountGhs: partsDepositGhs!,
                    currency: currency,
                    isLast: false,
                  ),
                  _NestedSplitRow(
                    label: RepairConstants.workmanshipBalanceLabel,
                    timing: showPaymentTiming
                        ? RepairConstants.workmanshipTiming
                        : null,
                    amountGhs: workmanshipGhs!,
                    currency: currency,
                    isLast: true,
                  ),
                ],
              ),
            ),
            if (partsDisplay != null && workmanshipDisplay != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$partsDisplay + $workmanshipDisplay',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _NestedSplitRow extends StatelessWidget {
  const _NestedSplitRow({
    required this.label,
    required this.amountGhs,
    required this.currency,
    required this.isLast,
    this.timing,
  });

  final String label;
  final double amountGhs;
  final CurrencyModel currency;
  final bool isLast;
  final String? timing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 10,
                  color: AppColors.secondary.withValues(alpha: 0.35),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 28,
                    color: AppColors.secondary.withValues(alpha: 0.2),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 8,
                      height: 2,
                      color: AppColors.secondary.withValues(alpha: 0.35),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.cardLabel.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (timing != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            timing!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  RepairGhsAmountColumn(
                    amountGhs: amountGhs,
                    currency: currency,
                    primaryStyle: AppTextStyles.cardLabel.copyWith(
                      color: AppColors.textPrimary,
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
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.amountGhs,
    required this.currency,
    this.subLabel,
    this.labelStyle,
    this.amountStyle,
  });

  final String label;
  final String? subLabel;
  final double amountGhs;
  final CurrencyModel currency;
  final TextStyle? labelStyle;
  final TextStyle? amountStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: labelStyle ?? AppTextStyles.cardLabel,
              ),
              if (subLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  subLabel!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        RepairGhsAmountColumn(
          amountGhs: amountGhs,
          currency: currency,
          primaryStyle: amountStyle,
        ),
      ],
    );
  }
}

/// Premium total footer — garage + platform fee.
class RepairQuoteTotalFooter extends StatelessWidget {
  const RepairQuoteTotalFooter({
    super.key,
    required this.label,
    required this.amountGhs,
    required this.currency,
    this.subLabel,
  });

  final String label;
  final String? subLabel;
  final double? amountGhs;
  final CurrencyModel currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.selectionTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subLabel != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subLabel!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          RepairGhsAmountColumn(
            amountGhs: amountGhs,
            currency: currency,
            primaryStyle: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Deposit due = parts deposit + platform fee (Request 1).
class RepairDepositDueSummary extends StatelessWidget {
  const RepairDepositDueSummary({
    super.key,
    required this.job,
    required this.currency,
    this.title,
    this.subtitle,
    this.accentStyle = RepairDepositSummaryStyle.dueNow,
  });

  final RepairJob job;
  final CurrencyModel currency;
  final String? title;
  final String? subtitle;
  final RepairDepositSummaryStyle accentStyle;

  @override
  Widget build(BuildContext context) {
    final parts = job.partsDepositGhs;
    final platformFee = job.effectivePlatformFeeGhs;
    final depositTotal = job.depositDueGhs;

    if (depositTotal == null || depositTotal <= 0) {
      return const SizedBox.shrink();
    }

    final heading = title ?? RepairConstants.repairDepositDueLabel;
    final body = subtitle ?? RepairConstants.repairDepositDueSub;
    final accentColor = switch (accentStyle) {
      RepairDepositSummaryStyle.dueNow => AppColors.amberText,
      RepairDepositSummaryStyle.afterApproval => AppColors.infoText,
    };
    final backgroundColor = switch (accentStyle) {
      RepairDepositSummaryStyle.dueNow => AppColors.amberBackground,
      RepairDepositSummaryStyle.afterApproval => AppColors.infoBackground,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.payments_outlined,
                size: 20,
                color: accentColor.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: AppTextStyles.caption.copyWith(
                        color: accentColor.withValues(alpha: 0.85),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppColors.borderSolid),
            ),
            child: Column(
              children: [
                if (parts != null)
                  _DepositLineRow(
                    label: RepairConstants.repairDepositPartsLine,
                    amountGhs: parts,
                    currency: currency,
                  ),
                if (parts != null && platformFee != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.borderSolid,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '+',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.borderSolid,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (platformFee != null)
                  _DepositLineRow(
                    label: RepairConstants.repairDepositPlatformLine,
                    amountGhs: platformFee,
                    currency: currency,
                  ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        RepairConstants.repairDepositTotalLine,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      RepairGhsAmountColumn(
                        amountGhs: depositTotal,
                        currency: currency,
                        primaryStyle: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum RepairDepositSummaryStyle { dueNow, afterApproval }

class _DepositLineRow extends StatelessWidget {
  const _DepositLineRow({
    required this.label,
    required this.amountGhs,
    required this.currency,
  });

  final String label;
  final double amountGhs;
  final CurrencyModel currency;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.cardLabel),
        RepairGhsAmountColumn(
          amountGhs: amountGhs,
          currency: currency,
        ),
      ],
    );
  }
}
