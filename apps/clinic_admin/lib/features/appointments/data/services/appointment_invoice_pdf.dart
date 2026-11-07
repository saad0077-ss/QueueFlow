
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/services/current_clinic_resolver.dart';
import '../../domain/entities/clinic_appointment_entity.dart';

/// Builds and downloads a branded PDF invoice for an appointment.
class AppointmentInvoicePdf {
  AppointmentInvoicePdf._();

  static const _brand = PdfColor.fromInt(0xFF2563EB);
  static const _brandDark = PdfColor.fromInt(0xFF1E3A8A);
  static const _ink = PdfColor.fromInt(0xFF0F172A);
  static const _muted = PdfColor.fromInt(0xFF64748B);
  static const _line = PdfColor.fromInt(0xFFE2E8F0);
  static const _soft = PdfColor.fromInt(0xFFF1F5F9);
  static const _green = PdfColor.fromInt(0xFF16A34A);
  static const _amber = PdfColor.fromInt(0xFFD97706);
  static const _red = PdfColor.fromInt(0xFFDC2626);

  /// Generates the invoice and saves/shares it (download on web).
  static Future<void> download(ClinicAppointmentEntity a) async {
    final bytes = await build(a);
    final name = 'Invoice-${a.bookingId}.pdf';
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: name);
    } else {
      await Printing.layoutPdf(name: name, onLayout: (_) async => bytes);
    }
  }

  static Future<Map<String, String>> _clinicInfo() async {
    try {
      final doc = await CurrentClinicResolver.resolve(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      );
      final d = doc?.data() ?? const <String, dynamic>{};
      String address = (d['address'] ?? '').toString();
      if (address.isEmpty && d['location'] is Map) {
        final loc = d['location'] as Map;
        address = [loc['building'], loc['street'], loc['city']]
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .join(', ');
      }
      return {
        'name': (d['name'] ?? 'Clinic').toString(),
        'address': address,
        'phone': (d['phone'] ?? '').toString(),
        'email': (d['adminEmail'] ?? d['email'] ?? '').toString(),
      };
    } catch (_) {
      return {'name': 'Clinic', 'address': '', 'phone': '', 'email': ''};
    }
  }

  static Future<Uint8List> build(ClinicAppointmentEntity a) async {
    final clinic = await _clinicInfo();

    // Inter has the ₹ glyph; fall back to built-in fonts (and "Rs.") offline.
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

    final pay = a.payment;
    final isCancelled = a.isCancelled;
    final PdfColor statusColor;
    final String statusText;
    if (pay.isRefunded) {
      statusColor = _amber;
      statusText = 'REFUNDED';
    } else if (isCancelled) {
      statusColor = _red;
      statusText = 'CANCELLED';
    } else if (pay.isPaid) {
      statusColor = _green;
      statusText = 'PAID';
    } else {
      statusColor = _amber;
      statusText = 'PAYMENT DUE';
    }

    final invoiceNo = pay.receiptNo.isNotEmpty
        ? pay.receiptNo
        : 'INV-${a.bookingId.replaceAll('QF-', '')}';
    final issued = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final issuedText = '${issued.day} ${months[issued.month - 1]} ${issued.year}';

    pw.Widget label(String t) => pw.Text(
          t.toUpperCase(),
          style: pw.TextStyle(font: bold, fontSize: 7.5, color: _muted, letterSpacing: 1),
        );

    pw.Widget value(String t, {bool strong = false, double size = 10}) => pw.Text(
          t.isEmpty ? '—' : t,
          style: pw.TextStyle(font: strong ? bold : regular, fontSize: size, color: _ink),
        );

    pw.Widget field(String l, String v) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 9),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [label(l), pw.SizedBox(height: 2.5), value(v)],
          ),
        );

    pw.Widget infoRow(String l, String v, {PdfColor? color, bool strong = false}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3.5),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(l, style: pw.TextStyle(font: regular, fontSize: 9, color: _muted)),
              pw.SizedBox(width: 12),
              pw.Flexible(
                child: pw.Text(
                  v.isEmpty ? '—' : v,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(font: strong ? bold : regular, fontSize: 9, color: color ?? _ink),
                ),
              ),
            ],
          ),
        );

    pw.Widget card(String title, List<pw.Widget> children) => pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: _soft,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              label(title),
              pw.SizedBox(height: 8),
              ...children,
            ],
          ),
        );

    final doc = pw.Document(
      title: 'Invoice ${a.bookingId}',
      author: clinic['name'],
      creator: 'QueueFlow',
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header band ──
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.fromLTRB(40, 36, 40, 28),
                decoration: const pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [_brandDark, _brand],
                    begin: pw.Alignment.topLeft,
                    end: pw.Alignment.bottomRight,
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            clinic['name']!,
                            style: pw.TextStyle(font: bold, fontSize: 20, color: PdfColors.white),
                          ),
                          pw.SizedBox(height: 6),
                          if (clinic['address']!.isNotEmpty)
                            pw.Text(clinic['address']!,
                                style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.blue100)),
                          if (clinic['phone']!.isNotEmpty)
                            pw.Text(clinic['phone']!,
                                style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.blue100)),
                          if (clinic['email']!.isNotEmpty)
                            pw.Text(clinic['email']!,
                                style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.blue100)),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            font: bold,
                            fontSize: 26,
                            color: PdfColors.white,
                            letterSpacing: 3,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text('# $invoiceNo',
                            style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.blue100)),
                        pw.Text('Issued $issuedText',
                            style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.blue100)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(40, 28, 40, 0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // ── Billed to / status ──
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              label('Billed to'),
                              pw.SizedBox(height: 5),
                              pw.Text(a.customerName,
                                  style: pw.TextStyle(font: bold, fontSize: 15, color: _ink)),
                              pw.SizedBox(height: 3),
                              if (a.phone.isNotEmpty)
                                pw.Text(a.phone,
                                    style: pw.TextStyle(font: regular, fontSize: 9.5, color: _muted)),
                              if (a.email.isNotEmpty)
                                pw.Text(a.email,
                                    style: pw.TextStyle(font: regular, fontSize: 9.5, color: _muted)),
                            ],
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: statusColor, width: 1.4),
                          ),
                          child: pw.Text(
                            statusText,
                            style: pw.TextStyle(
                              font: bold,
                              fontSize: 10.5,
                              color: statusColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 22),

                    // ── Appointment details ──
                    pw.Container(
                      padding: const pw.EdgeInsets.all(14),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: _line),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(child: field('Booking reference', a.bookingId)),
                          pw.Expanded(child: field('Consulting doctor', a.doctor)),
                          pw.Expanded(child: field('Department', a.departmentName)),
                          pw.Expanded(child: field('Date & time', a.dateTime)),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 22),

                    // ── Items table ──
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: pw.BoxDecoration(
                        color: _brand,
                        borderRadius: const pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(8),
                          topRight: pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text('SERVICE',
                                style: pw.TextStyle(font: bold, fontSize: 8, color: PdfColors.white, letterSpacing: 1)),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text('DURATION',
                                style: pw.TextStyle(font: bold, fontSize: 8, color: PdfColors.white, letterSpacing: 1)),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text('AMOUNT',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(font: bold, fontSize: 8, color: PdfColors.white, letterSpacing: 1)),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: _line),
                        borderRadius: const pw.BorderRadius.only(
                          bottomLeft: pw.Radius.circular(8),
                          bottomRight: pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                value(a.service, strong: true, size: 11),
                                if (a.notes.isNotEmpty) ...[
                                  pw.SizedBox(height: 3),
                                  pw.Text(a.notes,
                                      maxLines: 2,
                                      style: pw.TextStyle(font: regular, fontSize: 8.5, color: _muted)),
                                ],
                              ],
                            ),
                          ),
                          pw.Expanded(flex: 2, child: value(a.serviceDuration)),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: value(money(a.servicePrice), strong: true, size: 11),
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 16),

                    // ── Totals ──
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.SizedBox(
                        width: 230,
                        child: pw.Column(
                          children: [
                            infoRow('Subtotal', money(a.servicePrice)),
                            infoRow('Tax', money(0)),
                            pw.Divider(color: _line, height: 14),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Total',
                                    style: pw.TextStyle(font: bold, fontSize: 12, color: _ink)),
                                pw.Text(money(a.servicePrice),
                                    style: pw.TextStyle(font: bold, fontSize: 16, color: _brand)),
                              ],
                            ),
                            pw.SizedBox(height: 6),
                            infoRow(
                              pay.isPaid || pay.isRefunded ? 'Amount paid' : 'Balance due',
                              money(pay.isPaid || pay.isRefunded ? pay.amount : a.servicePrice),
                              color: statusColor,
                              strong: true,
                            ),
                            if (pay.isRefunded && pay.refundAmount != null)
                              infoRow('Refunded', '- ${money(pay.refundAmount!)}',
                                  color: _amber, strong: true),
                          ],
                        ),
                      ),
                    ),

                    pw.SizedBox(height: 20),

                    // ── Payment details ──
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: card('Payment details', [
                            infoRow('Method', pay.isPaid || pay.isRefunded ? pay.method : 'Pay at clinic'),
                            infoRow('Gateway', pay.gateway),
                            if (pay.paymentId.isNotEmpty) infoRow('Transaction ID', pay.paymentId),
                            if (pay.orderId.isNotEmpty) infoRow('Order ID', pay.orderId),
                            infoRow('Paid on', pay.paidAt),
                          ]),
                        ),
                        if (pay.isRefunded) ...[
                          pw.SizedBox(width: 14),
                          pw.Expanded(
                            child: card('Refund', [
                              infoRow('Amount', money(pay.refundAmount ?? pay.amount), color: _amber, strong: true),
                              if (pay.refundId != null) infoRow('Refund ID', pay.refundId!),
                              infoRow('Status', pay.refundStatus == 'processed' ? 'Processed' : 'Pending'),
                              if (pay.refundNote != null) infoRow('Note', pay.refundNote!),
                            ]),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // ── Footer ──
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                decoration: const pw.BoxDecoration(
                  color: _soft,
                  border: pw.Border(top: pw.BorderSide(color: _line)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Thank you for choosing ${clinic['name']}. Wishing you good health!',
                      style: pw.TextStyle(font: regular, fontSize: 9, color: _muted),
                    ),
                    pw.Text(
                      'Powered by QueueFlow',
                      style: pw.TextStyle(font: bold, fontSize: 9, color: _brand),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }
}
