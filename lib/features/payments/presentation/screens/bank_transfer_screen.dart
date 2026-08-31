import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/card_container.dart';
import '../../../../core/widgets/standalone_mobile_screen_scaffold.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_panel_chrome.dart';
import '../../../support/presentation/widgets/support_contact_section.dart';
import '../../data/services/bank_transfer_invoice_service.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/entities/payment_request.dart';
import '../providers/payment_providers.dart';

class BankTransferScreen extends ConsumerStatefulWidget {
  const BankTransferScreen({
    super.key,
    required this.orderId,
    required this.requestId,
    this.embedInWebPanel = false,
    this.onClosePanel,
  });

  final String orderId;
  final String requestId;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;

  @override
  ConsumerState<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends ConsumerState<BankTransferScreen> {
  String? _selectedAccountId;
  String? _downloadingAccountId;

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(paymentRequestProvider(widget.requestId));
    final orderAsync = ref.watch(orderProvider(widget.orderId));
    final orderReference = orderAsync.valueOrNull?.orderRef ?? widget.orderId;

    final body = requestAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _UnavailableCard(
        message: 'Could not load this payment request. Please try again.',
      ),
      data: (request) {
        if (request == null || !request.isPending) {
          return const _UnavailableCard(
            message: 'This payment request is no longer available.',
          );
        }
        return _buildContent(request, orderReference);
      },
    );

    if (widget.embedInWebPanel) {
      return OrderDetailWebPanelChrome(
        title: 'Bank transfer',
        orderRef: orderReference,
        onBack: widget.onClosePanel ?? () {},
        child: body,
      );
    }

    return StandaloneMobileScreenScaffold(
      title: 'Bank transfer',
      onBack: () => context.pop(),
      actions: [standaloneOrderRefTrailing(orderReference)],
      body: body,
    );
  }

  Widget _buildContent(PaymentRequest request, String orderReference) {
    final accountsAsync = ref.watch(activeBankAccountsProvider('GHS'));
    final preferredCurrency = ref.watch(preferredCurrencyProvider);
    final rate = preferredCurrency.code == 'GHS'
        ? preferredCurrency.usdToRate
        : request.exchangeRateAtRequest > 0
        ? request.exchangeRateAtRequest
        : 15.4;
    final amountGhs = request.amountUsd * rate;
    final amount = NumberFormat.currency(
      name: 'GHS',
      symbol: 'GHS ',
      decimalDigits: 2,
    ).format(amountGhs);
    final reference = bankTransferReference(request.id);

    return accountsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _UnavailableCard(
        message: 'Bank transfer details are temporarily unavailable.',
      ),
      data: (accounts) {
        if (accounts.isEmpty) {
          return const _UnavailableCard(
            message:
                'Bank transfer is not currently available for GHS payments.',
          );
        }
        final selected = accounts.firstWhere(
          (account) => account.id == _selectedAccountId,
          orElse: () => accounts.first,
        );
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: DashboardLayout.flowScrollPadding(
                  context,
                  top: 16,
                  bottom: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TransferSummaryCard(
                      amount: amount,
                      reference: reference,
                      onCopyAmount: () => _copy(
                        amount.replaceAll('GHS ', ''),
                        message: 'Amount copied',
                      ),
                      onCopyReference: () => _copy(
                        reference,
                        message: 'Transfer reference copied',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Send payment to', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    for (final account in accounts) ...[
                      _BankAccountCard(
                        account: account,
                        selected: account.id == selected.id,
                        showSelection: accounts.length > 1,
                        onSelected: () =>
                            setState(() => _selectedAccountId = account.id),
                        onCopyAccount: () => _copy(
                          account.accountNumber,
                          message: 'Account number copied',
                        ),
                        onCopySwift:
                            account.swiftCode?.trim().isNotEmpty == true
                            ? () => _copy(
                                account.swiftCode!.trim(),
                                message: 'SWIFT code copied',
                              )
                            : null,
                      ),
                      if (account != accounts.last) const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 14),
                    _InstructionsCard(instructions: selected.instructions),
                    const SizedBox(height: 12),
                    _ImportantNote(deadline: request.deadlineAt),
                    const SizedBox(height: 12),
                    Text(
                      'You can return and pay online instead. Viewing these details does not change your payment request.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _StickyActions(
              downloading: _downloadingAccountId == selected.id,
              onDownload: () => _downloadInvoice(
                request: request,
                account: selected,
                orderReference: orderReference,
                transferReference: reference,
                amountGhs: amountGhs,
              ),
              onAssistance: () => _showAssistance(request.createdByAgentId),
            ),
          ],
        );
      },
    );
  }

  Future<void> _copy(String value, {String? message}) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showAssistance(String agentId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final agentAsync = ref.watch(agentForPaymentProvider(agentId));
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderSolid,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  agentAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SupportContactSection(
                      showHours: false,
                      compact: true,
                      heading: 'Get transfer assistance',
                      subheading:
                          'Contact support before or after sending payment.',
                    ),
                    data: (agent) => _PaymentContactSection(agent: agent),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadInvoice({
    required PaymentRequest request,
    required BankAccount account,
    required String orderReference,
    required String transferReference,
    required double amountGhs,
  }) async {
    if (_downloadingAccountId != null) return;
    setState(() => _downloadingAccountId = account.id);
    try {
      final customer = await ref.read(currentUserProvider.future);
      if (customer == null) throw StateError('Customer profile unavailable');
      await const BankTransferInvoiceService().downloadInvoice(
        request: request,
        bankAccount: account,
        customer: customer,
        orderReference: orderReference,
        transferReference: transferReference,
        amountGhs: amountGhs,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not generate the invoice. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingAccountId = null);
    }
  }
}

String bankTransferReference(String paymentRequestId) {
  final clean = paymentRequestId.replaceAll(RegExp('[^A-Za-z0-9]'), '');
  final suffix = clean.length <= 10
      ? clean
      : clean.substring(clean.length - 10);
  return 'WPL-${suffix.toUpperCase()}';
}

class _TransferSummaryCard extends StatelessWidget {
  const _TransferSummaryCard({
    required this.amount,
    required this.reference,
    required this.onCopyAmount,
    required this.onCopyReference,
  });

  final String amount;
  final String reference;
  final VoidCallback onCopyAmount;
  final VoidCallback onCopyReference;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173F78), AppColors.brand],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BANK TRANSFER',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  amount,
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _HeroCopyButton(tooltip: 'Copy amount', onTap: onCopyAmount),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRANSFER REFERENCE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.68),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 3),
                      SelectableText(
                        reference,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _HeroCopyButton(
                  tooltip: 'Copy transfer reference',
                  onTap: onCopyReference,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopyButton extends StatelessWidget {
  const _HeroCopyButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.14),
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.copy_rounded, size: 19),
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  const _BankAccountCard({
    required this.account,
    required this.selected,
    required this.showSelection,
    required this.onSelected,
    required this.onCopyAccount,
    this.onCopySwift,
  });

  final BankAccount account;
  final bool selected;
  final bool showSelection;
  final VoidCallback onSelected;
  final VoidCallback onCopyAccount;
  final VoidCallback? onCopySwift;

  @override
  Widget build(BuildContext context) {
    final hasMore = [
      account.currency,
      account.branchName,
      account.branchAddress,
      account.swiftCode,
      account.routingNumber,
      account.iban,
    ].any((value) => value?.trim().isNotEmpty == true);

    return CardContainer(
      paddingType: CardContainerPaddingType.none,
      child: InkWell(
        onTap: showSelection ? onSelected : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.brandMuted,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.bankName,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account.accountName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showSelection)
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected
                          ? AppColors.brand
                          : AppColors.textTertiary,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 11, 8, 11),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACCOUNT NUMBER',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 3),
                          SelectableText(
                            account.accountNumber,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy account number',
                      onPressed: onCopyAccount,
                      icon: const Icon(Icons.copy_rounded, size: 19),
                    ),
                  ],
                ),
              ),
              if (hasMore) ...[
                const SizedBox(height: 6),
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: Text(
                      'Additional bank details',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      _DetailRow(label: 'Currency', value: account.currency),
                      if (account.branchName?.trim().isNotEmpty == true)
                        _DetailRow(
                          label: 'Branch',
                          value: account.branchName!.trim(),
                        ),
                      if (account.branchAddress?.trim().isNotEmpty == true)
                        _DetailRow(
                          label: 'Address',
                          value: account.branchAddress!.trim(),
                        ),
                      if (account.swiftCode?.trim().isNotEmpty == true)
                        _DetailRow(
                          label: 'SWIFT code',
                          value: account.swiftCode!.trim(),
                          onCopy: onCopySwift,
                        ),
                      if (account.routingNumber?.trim().isNotEmpty == true)
                        _DetailRow(
                          label: 'Routing number',
                          value: account.routingNumber!.trim(),
                        ),
                      if (account.iban?.trim().isNotEmpty == true)
                        _DetailRow(label: 'IBAN', value: account.iban!.trim()),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.onCopy});

  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: AppTextStyles.bodySmall),
          ),
          if (onCopy != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Copy $label',
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded, size: 17),
            ),
        ],
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({required this.instructions});

  final List<String> instructions;

  @override
  Widget build(BuildContext context) {
    final items = instructions.isEmpty
        ? const [
            'Transfer the exact amount shown above.',
            'Use the transfer reference exactly as displayed.',
            'Transfers without the correct reference may take longer to verify.',
          ]
        : instructions;
    return CardContainer(
      paddingType: CardContainerPaddingType.large,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: AppColors.brand),
              const SizedBox(width: 9),
              Text('Transfer instructions', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          for (final entry in items.asMap().entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.brandMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${entry.key + 1}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.bodySmall.copyWith(height: 1.4),
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

class _StickyActions extends StatelessWidget {
  const _StickyActions({
    required this.downloading,
    required this.onDownload,
    required this.onAssistance,
  });

  final bool downloading;
  final VoidCallback onDownload;
  final VoidCallback onAssistance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderSolid.withValues(alpha: 0.8)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAssistance,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderSolid),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.support_agent_rounded),
                label: const Text('Get help'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: downloading ? null : onDownload,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: downloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(downloading ? 'Preparing…' : 'Download invoice'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportantNote extends StatelessWidget {
  const _ImportantNote({this.deadline});

  final DateTime? deadline;

  @override
  Widget build(BuildContext context) {
    final dueText = deadline == null
        ? ''
        : ' Complete it by ${DateFormat('d MMMM yyyy').format(deadline!)}.';
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.amberBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'The invoice is not proof of payment. Confirmation happens after funds reach the bank account.$dueText',
              style: AppTextStyles.bodySmall.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentContactSection extends StatelessWidget {
  const _PaymentContactSection({required this.agent});

  final AgentDetailView? agent;

  static String _whatsAppDigits(String value) =>
      value.replaceAll(RegExp(r'\D'), '');

  Future<void> _launch(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = agent?.phone?.trim();
    final whatsapp = agent?.whatsappNumberForContact?.trim();
    if (agent == null ||
        ((phone == null || phone.isEmpty) &&
            (whatsapp == null || whatsapp.isEmpty))) {
      return const SupportContactSection(
        showHours: false,
        compact: true,
        heading: 'Get transfer assistance',
        subheading: 'Contact support before or after sending payment.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Get transfer assistance', style: AppTextStyles.titleLarge),
        const SizedBox(height: 5),
        Text(
          'Contact ${agent!.fullName} for help or to let them know you made the transfer.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        if (phone != null && phone.isNotEmpty)
          SupportContactTile(
            icon: Icons.call_rounded,
            label: 'Call agent',
            number: phone,
            accentColor: AppColors.success,
            accentBg: AppColors.successMutedBackground,
            onTap: () => _launch(context, Uri(scheme: 'tel', path: phone)),
          ),
        if (phone != null &&
            phone.isNotEmpty &&
            whatsapp != null &&
            whatsapp.isNotEmpty)
          const SizedBox(height: 10),
        if (whatsapp != null && whatsapp.isNotEmpty)
          SupportContactTile(
            icon: Icons.chat_rounded,
            label: 'WhatsApp agent',
            number: whatsapp,
            accentColor: AppColors.whatsapp,
            accentBg: AppColors.whatsappMuted,
            onTap: () => _launch(
              context,
              Uri.parse('https://wa.me/${_whatsAppDigits(whatsapp)}'),
            ),
          ),
      ],
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: CardContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(message, style: AppTextStyles.bodyMedium)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
