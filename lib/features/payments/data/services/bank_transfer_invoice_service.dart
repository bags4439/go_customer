import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/entities/payment_request.dart';

class BankTransferInvoiceService {
  const BankTransferInvoiceService();

  Future<void> downloadInvoice({
    required PaymentRequest request,
    required BankAccount bankAccount,
    required AppUser customer,
    required String orderReference,
    required String transferReference,
    required double amountGhs,
  }) async {
    final bytes = await _buildInvoice(
      request: request,
      bankAccount: bankAccount,
      customer: customer,
      orderReference: orderReference,
      transferReference: transferReference,
      amountGhs: amountGhs,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Whiplyn-invoice-$transferReference.pdf',
    );
  }

  Future<Uint8List> _buildInvoice({
    required PaymentRequest request,
    required BankAccount bankAccount,
    required AppUser customer,
    required String orderReference,
    required String transferReference,
    required double amountGhs,
  }) async {
    final document = pw.Document(
      title: 'Whiplyn invoice $transferReference',
      author: 'Whiplyn',
    );
    final amount = NumberFormat.currency(
      name: 'GHS',
      symbol: 'GHS ',
      decimalDigits: 2,
    ).format(amountGhs);
    final issuedAt = DateFormat('d MMMM yyyy').format(DateTime.now());
    final muted = PdfColor.fromHex('#667085');
    final border = PdfColor.fromHex('#E4E7EC');
    final brand = PdfColor.fromHex('#009FE8');

    pw.Widget detail(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 115,
            child: pw.Text(
              label,
              style: pw.TextStyle(color: muted, fontSize: 9),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
          ),
        ],
      ),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(42),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'This invoice is a payment request and is not proof of payment.',
            style: pw.TextStyle(color: muted, fontSize: 8),
          ),
        ),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'WHIPLYN',
                    style: pw.TextStyle(
                      color: brand,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Bank transfer invoice',
                    style: pw.TextStyle(color: muted),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    transferReference,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Issued $issuedAt',
                    style: pw.TextStyle(color: muted, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 28),
          pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F5FBFE'),
              border: pw.Border.all(color: brand),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'AMOUNT DUE',
                  style: pw.TextStyle(color: muted, fontSize: 10),
                ),
                pw.Text(
                  amount,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Invoice details',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          detail('Customer', customer.fullName),
          detail('Phone', customer.phone),
          if (customer.email?.isNotEmpty == true)
            detail('Email', customer.email!),
          detail('Order', orderReference),
          detail('Payment request', request.description ?? request.type),
          if (request.deadlineAt != null)
            detail(
              'Due date',
              DateFormat('d MMMM yyyy').format(request.deadlineAt!),
            ),
          pw.SizedBox(height: 16),
          pw.Divider(color: border),
          pw.SizedBox(height: 16),
          pw.Text(
            'Bank details',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          detail('Bank', bankAccount.bankName),
          detail('Account name', bankAccount.accountName),
          detail('Account number', bankAccount.accountNumber),
          detail('Currency', bankAccount.currency),
          if (bankAccount.branchName?.isNotEmpty == true)
            detail('Branch', bankAccount.branchName!),
          if (bankAccount.swiftCode?.isNotEmpty == true)
            detail('SWIFT code', bankAccount.swiftCode!),
          if (bankAccount.routingNumber?.isNotEmpty == true)
            detail('Routing number', bankAccount.routingNumber!),
          if (bankAccount.iban?.isNotEmpty == true)
            detail('IBAN', bankAccount.iban!),
          pw.SizedBox(height: 16),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: border),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TRANSFER REFERENCE',
                  style: pw.TextStyle(color: muted, fontSize: 9),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  transferReference,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Enter this exact reference when making the transfer.',
                  style: pw.TextStyle(color: muted, fontSize: 9),
                ),
              ],
            ),
          ),
          if (bankAccount.instructions.isNotEmpty) ...[
            pw.SizedBox(height: 22),
            pw.Text(
              'Transfer instructions',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...bankAccount.instructions.asMap().entries.map(
              (entry) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 7),
                child: pw.Text(
                  '${entry.key + 1}. ${entry.value}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
    return document.save();
  }
}
