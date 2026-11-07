import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/billing/domain/entities/platform_invoice_entity.dart';
import '../../features/billing/domain/entities/platform_tenant_subscription_entity.dart';
import '../../features/dashboard/domain/entities/tenant_clinic_entity.dart';
import '../../features/departments/domain/entities/department_entity.dart';
import '../widgets/app_snack_bar.dart';

/// Builds and downloads/shares PDF reports for the platform admin app.
class PdfExporter {
  static String dateTag() {
    final n = DateTime.now();
    return '${n.year}${n.month.toString().padLeft(2, '0')}${n.day.toString().padLeft(2, '0')}';
  }

  static Future<Uint8List> _buildTable({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (_) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Generated ${DateTime.now().toString().substring(0, 16)}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            ],
          ),
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ),
        build: (_) => [
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(
                fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
            cellStyle: const pw.TextStyle(fontSize: 7.5),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.4),
          ),
        ],
      ),
    );
    return doc.save();
  }

  static Future<void> _export(
    BuildContext context, {
    required String title,
    required String fileName,
    required List<String> headers,
    required List<List<Object?>> rows,
  }) async {
    try {
      final bytes = await _buildTable(
        title: title,
        headers: headers,
        rows: [
          for (final r in rows) [for (final c in r) (c ?? '').toString()],
        ],
      );
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      if (context.mounted) {
        AppSnackBar.showSuccess(context, message: '$fileName exported successfully.');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showInfo(context, message: 'PDF export failed: $e');
      }
    }
  }

  static Future<void> exportInvoices(
      BuildContext context, List<PlatformInvoiceEntity> invoices) {
    return _export(
      context,
      title: 'QueueFlow - Invoices',
      fileName: 'queueflow_invoices_${dateTag()}.pdf',
      headers: const [
        'Invoice #', 'Clinic', 'Plan', 'Amount', 'Due Date', 'Issue Date', 'Status', 'Method'
      ],
      rows: [
        for (final i in invoices)
          [i.number, i.clinicName, i.plan, i.amount, i.dueDate, i.date, i.status, i.method],
      ],
    );
  }

  static Future<void> exportSubscriptions(
      BuildContext context, List<PlatformTenantSubscriptionEntity> subs) {
    return _export(
      context,
      title: 'QueueFlow - Subscriptions',
      fileName: 'queueflow_subscriptions_${dateTag()}.pdf',
      headers: const [
        'Clinic', 'Admin', 'Email', 'City', 'Category', 'Plan', 'Cycle', 'MRR', 'Status',
        'Doctors'
      ],
      rows: [
        for (final s in subs)
          [
            s.clinicName, s.adminName, s.adminEmail, s.city, s.category, s.planName,
            s.billingCadence, s.mrrAmount, s.status, s.practicingDoctors
          ],
      ],
    );
  }

  static Future<void> exportClinics(BuildContext context,
      List<TenantClinicEntity> clinics, Map<String, int> appointments) {
    return _export(
      context,
      title: 'QueueFlow - Clinics Directory',
      fileName: 'queueflow_clinics_${dateTag()}.pdf',
      headers: const [
        'Clinic', 'Admin', 'Email', 'Phone', 'Address', 'City', 'Plan', 'Status', 'Appts (Month)'
      ],
      rows: [
        for (final c in clinics)
          [
            c.name, c.adminName, c.adminEmail, c.phone, c.address, c.city, c.planName,
            c.status, appointments[c.id] ?? 0
          ],
      ],
    );
  }

  static Future<void> exportDepartments(
      BuildContext context, List<DepartmentEntity> depts) {
    return _export(
      context,
      title: 'QueueFlow - Departments',
      fileName: 'queueflow_departments_${dateTag()}.pdf',
      headers: const [
        'Name', 'Code', 'Description', 'Avg Consultation', 'Status', 'Doctors',
        'Monthly Visits', 'Clinics'
      ],
      rows: [
        for (final d in depts)
          [
            d.name, d.code, d.description, d.avgConsultationTime, d.status, d.doctorCount,
            d.totalVisits, d.assignedClinics.length
          ],
      ],
    );
  }
}
