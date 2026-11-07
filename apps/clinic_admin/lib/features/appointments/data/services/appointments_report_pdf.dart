import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/services/current_clinic_resolver.dart';
import '../../domain/entities/clinic_appointment_entity.dart';

/// Builds a branded, print-ready PDF report of a list of appointments.
class AppointmentsReportPdf {
  AppointmentsReportPdf._();

  static const _brand = PdfColor.fromInt(0xFF2563EB);
  static const _brandDark = PdfColor.fromInt(0xFF1E3A8A);
  static const _ink = PdfColor.fromInt(0xFF0F172A);
  static const _muted = PdfColor.fromInt(0xFF64748B);
  static const _line = PdfColor.fromInt(0xFFE2E8F0);
  static const _soft = PdfColor.fromInt(0xFFF8FAFC);
  static const _green = PdfColor.fromInt(0xFF16A34A);
  static const _amber = PdfColor.fromInt(0xFFD97706);
  static const _red = PdfColor.fromInt(0xFFDC2626);
  static const _blue = PdfColor.fromInt(0xFF2563EB);

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Generates the report and downloads/prints it.
  static Future<void> download(List<ClinicAppointmentEntity> items) async {
    final bytes = await build(items);
    final now = DateTime.now();
    final name =
        'Appointments-Report-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf';
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: name);
    } else {
      await Printing.layoutPdf(name: name, onLayout: (_) async => bytes);
    }
  }

  static Future<String> _clinicName() async {
    try {
      final doc = await CurrentClinicResolver.resolve(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      );
      final name = (doc?.data()?['name'] ?? '').toString();
      return name.isEmpty ? 'Clinic' : name;
    } catch (_) {
      return 'Clinic';
    }
  }

  static PdfColor _statusColor(ClinicAppointmentEntity a) {
    if (a.isCancelled) return _red;
    if (a.isCompleted) return _green;
    if (a.isCheckedIn) return _amber;
    return _blue;
  }

  static String _statusLabel(ClinicAppointmentEntity a) {
    final s = a.status.toLowerCase();
    if (s == 'checkedin' || s == 'checked-in') return 'Checked in';
    if (s.isEmpty) return '-';
    return s[0].toUpperCase() + s.substring(1);
  }

  static Future<Uint8List> build(List<ClinicAppointmentEntity> items) async {
    final clinic = await _clinicName();

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

    final total = items.length;
    final completed = items.where((a) => a.isCompleted).length;
    final cancelled = items.where((a) => a.isCancelled).length;
    final upcoming = total - completed - cancelled;
    final revenue = items
        .where((a) => a.payment.isPaid)
        .fold<double>(0, (s, a) => s + a.payment.amount);

    final now = DateTime.now();
    final generated =
        '${now.day} ${_months[now.month - 1]} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    pw.Widget statCard(String label, String value, PdfColor color) {
      return pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: pw.BoxDecoration(
            color: _soft,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: _line, width: 0.8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 18,
                height: 3,
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                label.toUpperCase(),
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 7.5,
                  color: _muted,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                value,
                style: pw.TextStyle(font: bold, fontSize: 17, color: _ink),
              ),
            ],
          ),
        ),
      );
    }

    pw.Widget cell(
      String text, {
      bool strong = false,
      PdfColor? color,
      pw.Alignment align = pw.Alignment.centerLeft,
    }) {
      return pw.Container(
        alignment: align,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        child: pw.Text(
          text.isEmpty ? '-' : text,
          maxLines: 2,
          style: pw.TextStyle(
            font: strong ? bold : regular,
            fontSize: 8,
            color: color ?? _ink,
          ),
        ),
      );
    }

    pw.Widget head(String text, {pw.Alignment align = pw.Alignment.centerLeft}) {
      return pw.Container(
        alignment: align,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: pw.Text(
          text.toUpperCase(),
          style: pw.TextStyle(
            font: bold,
            fontSize: 7,
            color: PdfColors.white,
            letterSpacing: 0.8,
          ),
        ),
      );
    }

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(
          color: _brandDark,
          borderRadius: pw.BorderRadius.only(
            topLeft: pw.Radius.circular(6),
            topRight: pw.Radius.circular(6),
          ),
        ),
        children: [
          head('Booking'),
          head('Patient'),
          head('Service'),
          head('Doctor'),
          head('Date & time'),
          head('Status'),
          head('Payment'),
          head('Amount', align: pw.Alignment.centerRight),
        ],
      ),
      for (var i = 0; i < items.length; i++)
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i.isEven ? PdfColors.white : _soft,
            border: const pw.Border(
              bottom: pw.BorderSide(color: _line, width: 0.5),
            ),
          ),
          children: [
            cell(items[i].bookingId, strong: true, color: _brand),
            cell(items[i].customerName, strong: true),
            cell(items[i].service),
            cell(items[i].doctor),
            cell('${items[i].dateRaw} ${items[i].timeRaw}'.trim()),
            cell(
              _statusLabel(items[i]),
              strong: true,
              color: _statusColor(items[i]),
            ),
            cell(
              items[i].payment.status.isEmpty
                  ? '-'
                  : items[i].payment.status[0].toUpperCase() +
                        items[i].payment.status.substring(1),
            ),
            cell(
              money(items[i].payment.amount),
              strong: true,
              align: pw.Alignment.centerRight,
            ),
          ],
        ),
    ];

    final doc = pw.Document(title: 'Appointments Report', author: clinic);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 36),
        footer: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated by QueueFlow  •  $generated',
                style: pw.TextStyle(font: regular, fontSize: 7.5, color: _muted),
              ),
              pw.Text(
                'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style: pw.TextStyle(font: regular, fontSize: 7.5, color: _muted),
              ),
            ],
          ),
        ),
        build: (ctx) => [
          // Banner
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(22, 20, 22, 20),
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(12),
              gradient: const pw.LinearGradient(
                colors: [_brandDark, _brand],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      clinic.toUpperCase(),
                      style: pw.TextStyle(
                        font: bold,
                        fontSize: 8,
                        color: PdfColors.white,
                        letterSpacing: 1.6,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Appointments Report',
                      style: pw.TextStyle(
                        font: bold,
                        fontSize: 22,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'GENERATED',
                      style: pw.TextStyle(
                        font: bold,
                        fontSize: 7,
                        color: PdfColors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      generated,
                      style: pw.TextStyle(
                        font: bold,
                        fontSize: 10,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          // Stats
          pw.Row(
            children: [
              statCard('Total', '$total', _brand),
              pw.SizedBox(width: 10),
              statCard('Upcoming / active', '$upcoming', _amber),
              pw.SizedBox(width: 10),
              statCard('Completed', '$completed', _green),
              pw.SizedBox(width: 10),
              statCard('Cancelled', '$cancelled', _red),
              pw.SizedBox(width: 10),
              statCard('Revenue collected', money(revenue), _brandDark),
            ],
          ),
          pw.SizedBox(height: 18),
          if (items.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(30),
              alignment: pw.Alignment.center,
              child: pw.Text(
                'No appointments match the current filters.',
                style: pw.TextStyle(font: regular, fontSize: 11, color: _muted),
              ),
            )
          else
            pw.Table(
              columnWidths: const {
                0: pw.FlexColumnWidth(1.3),
                1: pw.FlexColumnWidth(1.7),
                2: pw.FlexColumnWidth(1.8),
                3: pw.FlexColumnWidth(1.6),
                4: pw.FlexColumnWidth(1.7),
                5: pw.FlexColumnWidth(1.1),
                6: pw.FlexColumnWidth(1.0),
                7: pw.FlexColumnWidth(1.1),
              },
              children: rows,
            ),
        ],
      ),
    );
    return doc.save();
  }
}
