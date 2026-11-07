
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/billing_dates.dart';
import '../../domain/entities/billing_invoice_entity.dart';

/// Builds a professional PDF payment receipt for a subscription payment.
/// Every value comes from the stored (backend-verified) transaction.
class BillingReceiptPdf {
  BillingReceiptPdf._();

  static const _brand = PdfColor.fromInt(0xFF2563EB);
  static const _brandDark = PdfColor.fromInt(0xFF1E3A8A);
  static const _ink = PdfColor.fromInt(0xFF0F172A);
  static const _muted = PdfColor.fromInt(0xFF64748B);
  static const _line = PdfColor.fromInt(0xFFE2E8F0);
  static const _soft = PdfColor.fromInt(0xFFF1F5F9);
  static const _green = PdfColor.fromInt(0xFF16A34A);

  static Future<void> download(BillingInvoiceEntity inv) async {
    final bytes = await build(inv);
    final name = 'Receipt-${inv.number}.pdf';
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: name);
    } else {
      await Printing.layoutPdf(name: name, onLayout: (_) async => bytes);
    }
  }

  static Future<Uint8List> build(BillingInvoiceEntity inv) async {
    pw.Font regular, bold;
    var rupee = '₹';
    try {
      regular = await PdfGoogleFonts.interRegular();
      bold = await PdfGoogleFonts.interBold();
    } catch (_) {
      regular = pw.Font.helvetica();
      bold = pw.Font.helveticaBold();
      rupee = 'Rs. ';
    }

    String money(num v) => '$rupee${v.toStringAsFixed(2)}';
    String dash(String? v) => (v == null || v.trim().isEmpty) ? '-' : v;

    final total = inv.subtotal > 0
        ? inv.subtotal + inv.tax
        : (num.tryParse(inv.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0);
    final subtotal = inv.subtotal > 0 ? inv.subtotal : total - inv.tax;
    final paidAt = inv.paidAt ?? inv.createdAt;
    final customer = inv.customerName.isNotEmpty ? inv.customerName : inv.clinic;

    pw.Widget label(String t) => pw.Text(
          t.toUpperCase(),
          style: pw.TextStyle(font: bold, fontSize: 7.5, color: _muted, letterSpacing: 1),
        );

    pw.Widget field(String l, String v, {bool strong = false}) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              label(l),
              pw.SizedBox(height: 3),
              pw.Text(v, style: pw.TextStyle(font: strong ? bold : regular, fontSize: 10.5, color: _ink)),
            ],
          ),
        );

    pw.Widget amountRow(String l, String v, {bool big = false, PdfColor? color}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(l, style: pw.TextStyle(font: big ? bold : regular, fontSize: big ? 12 : 10, color: big ? _ink : _muted)),
              pw.Text(v, style: pw.TextStyle(font: bold, fontSize: big ? 15 : 10, color: color ?? _ink)),
            ],
          ),
        );

    final doc = pw.Document(title: 'Payment Receipt ${inv.number}', author: 'QueueFlow');
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => pw.Container(
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(14),
            border: pw.Border.all(color: _line, width: 1),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header band
              pw.Container(
                padding: const pw.EdgeInsets.fromLTRB(28, 24, 28, 24),
                decoration: const pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [_brandDark, _brand],
                    begin: pw.Alignment.topLeft,
                    end: pw.Alignment.bottomRight,
                  ),
                  borderRadius: pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(13),
                    topRight: pw.Radius.circular(13),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Row(children: [
                      pw.Container(
                        width: 38,
                        height: 38,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Text('Q', style: pw.TextStyle(font: bold, fontSize: 22, color: _brand)),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('QueueFlow', style: pw.TextStyle(font: bold, fontSize: 18, color: PdfColors.white)),
                        pw.SizedBox(height: 2),
                        pw.Text('Book smarter. Wait less.', style: pw.TextStyle(font: regular, fontSize: 8.5, color: PdfColors.white)),
                      ]),
                    ]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                      pw.Text('PAYMENT RECEIPT', style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white, letterSpacing: 1.6)),
                      pw.SizedBox(height: 4),
                      pw.Text(inv.number, style: pw.TextStyle(font: bold, fontSize: 12, color: PdfColors.white)),
                    ]),
                  ],
                ),
              ),

              pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(28, 24, 28, 24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Status + amount
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                          label('Amount paid'),
                          pw.SizedBox(height: 4),
                          pw.Text(money(total), style: pw.TextStyle(font: bold, fontSize: 28, color: _ink)),
                        ]),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: _green, width: 1.4)),
                          child: pw.Text('PAID', style: pw.TextStyle(font: bold, fontSize: 11, color: _green, letterSpacing: 1.4)),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 22),

                    // Details grid
                    pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Expanded(
                        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                          field('Billed to', dash(customer), strong: true),
                          field('Account email', dash(inv.customerEmail)),
                          field('Clinic', dash(inv.clinic)),
                          field('Transaction ID', dash(inv.paymentId)),
                        ]),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Expanded(
                        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                          field('Receipt number', inv.number, strong: true),
                          field('Payment date & time', paidAt != null ? formatBillingDateTime(paidAt) : dash(inv.date)),
                          field('Payment method', dash(inv.method)),
                          field('Payment status', 'Paid'),
                        ]),
                      ),
                    ]),

                    pw.SizedBox(height: 6),
                    // Plan table
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(color: _soft, borderRadius: pw.BorderRadius.circular(10)),
                      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        label('Subscription plan'),
                        pw.SizedBox(height: 4),
                        pw.Text(inv.plan, style: pw.TextStyle(font: bold, fontSize: 14, color: _ink)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          inv.billingCycle == 'annual' ? 'Annual subscription' : 'Monthly subscription',
                          style: pw.TextStyle(font: regular, fontSize: 9.5, color: _muted),
                        ),
                        pw.SizedBox(height: 14),
                        pw.Row(children: [
                          pw.Expanded(child: field('Subscription start date', inv.startAt != null ? formatBillingDate(inv.startAt!) : '-')),
                          pw.Expanded(child: field('Subscription expiry date', inv.endAt != null ? formatBillingDate(inv.endAt!) : '-')),
                        ]),
                      ]),
                    ),

                    pw.SizedBox(height: 18),
                    // Amounts
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                      child: pw.Column(children: [
                        amountRow('Plan price', money(subtotal)),
                        amountRow('Taxes', inv.tax > 0 ? money(inv.tax) : 'None applicable'),
                        pw.Divider(color: _line, height: 14),
                        amountRow('Total amount paid', money(total), big: true, color: _brand),
                      ]),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: _line, width: 1)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('This is a computer-generated receipt and needs no signature.',
                        style: pw.TextStyle(font: regular, fontSize: 8, color: _muted)),
                    pw.Text('Thank you for choosing QueueFlow',
                        style: pw.TextStyle(font: bold, fontSize: 8.5, color: _brand)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return doc.save();
  }
}
