import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/billing/domain/entities/platform_invoice_entity.dart';
import '../../features/billing/domain/entities/platform_tenant_subscription_entity.dart';
import '../../features/dashboard/domain/entities/tenant_clinic_entity.dart';
import '../../features/departments/domain/entities/department_entity.dart';
import '../../features/reports/domain/entities/platform_report_entity.dart';
import '../../features/tickets/domain/entities/platform_support_ticket_entity.dart';
import '../../features/users/domain/entities/platform_user_entity.dart';
import '../widgets/app_snack_bar.dart';

/// Unified, reusable PDF exporter for QueueFlow Platform Operations & Administration.
class PdfExporter {
  static String dateTag() {
    final n = DateTime.now();
    return '${n.year}${n.month.toString().padLeft(2, '0')}${n.day.toString().padLeft(2, '0')}';
  }

  /// Builds a high-contrast, executive landscape PDF document with branding and metadata.
  static Future<Uint8List> buildTable({
    required String title,
    String? subtitle,
    required List<String> headers,
    required List<List<String>> rows,
    Map<String, String>? metadata,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (_) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFCBD5E1), width: 1),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'QueueFlow Healthcare Platform',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF2563EB),
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF0F172A),
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    pw.SizedBox(height: 1),
                    pw.Text(
                      subtitle,
                      style: const pw.TextStyle(
                        fontSize: 8.5,
                        color: PdfColor.fromInt(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Generated: ${DateTime.now().toString().substring(0, 16)}',
                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColor.fromInt(0xFF64748B)),
                  ),
                  if (metadata != null)
                    pw.Text(
                      metadata.entries.map((e) => '${e.key}: ${e.value}').join('  •  '),
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF0F172A),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        footer: (ctx) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 10),
          padding: const pw.EdgeInsets.only(top: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.8),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'QueueFlow Platform Operations • Confidential Administration Ledger',
                style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF94A3B8)),
              ),
              pw.Text(
                'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF64748B)),
              ),
            ],
          ),
        ),
        build: (_) => [
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1E3A8A)),
            headerAlignment: pw.Alignment.centerLeft,
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 7.5),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF8FAFC)),
            border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFFCBD5E1), width: 0.4),
          ),
        ],
      ),
    );

    return doc.save();
  }

  /// Generic table export function reused across all Platform Admin features.
  static Future<void> exportTable(
    BuildContext context, {
    required String title,
    String? subtitle,
    required String fileName,
    required List<String> headers,
    required List<List<Object?>> rows,
    Map<String, String>? metadata,
  }) async {
    try {
      final bytes = await buildTable(
        title: title,
        subtitle: subtitle,
        headers: headers,
        rows: [
          for (final r in rows) [for (final c in r) (c ?? '').toString()],
        ],
        metadata: metadata,
      );
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      if (context.mounted) {
        AppSnackBar.showSuccess(
          context,
          message: '$fileName generated successfully.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, message: 'PDF export failed: $e');
      }
    }
  }

  /// Exports Platform Support & SLA Tickets to PDF.
  static Future<void> exportTickets(
    BuildContext context,
    List<PlatformSupportTicketEntity> tickets,
  ) {
    return exportTable(
      context,
      title: 'QueueFlow - Platform Support & SLA Tickets',
      subtitle: 'Global Tenant Support, Doctor Escalation & Concern Telemetry',
      fileName: 'queueflow_support_tickets_${dateTag()}.pdf',
      metadata: {'Total Tickets': '${tickets.length}'},
      headers: const [
        'Ticket #',
        'Patient Name',
        'Phone',
        'Clinic',
        'Category',
        'Subject',
        'Priority',
        'Status',
        'SLA Target',
        'Created',
      ],
      rows: [
        for (final t in tickets)
          [
            t.ticketNumber,
            t.patientName,
            t.patientPhone,
            t.clinicName,
            t.category.toUpperCase(),
            t.subject,
            t.priority.toUpperCase(),
            t.status.toUpperCase(),
            t.slaNotice,
            t.createdAt,
          ],
      ],
    );
  }

  /// Exports Registered Platform Users & Patients Directory to PDF.
  static Future<void> exportUsers(
    BuildContext context,
    List<PlatformUserEntity> users,
  ) {
    return exportTable(
      context,
      title: 'QueueFlow - Registered Patients & Users Directory',
      subtitle: 'Global Patient Records, Clinic Affiliation & Queue History',
      fileName: 'queueflow_users_${dateTag()}.pdf',
      metadata: {'Total Records': '${users.length}'},
      headers: const [
        'Health ID',
        'Patient Name',
        'Phone',
        'Email',
        'Age / Gender',
        'Home Clinic',
        'Bookings',
        'Queues',
        'Status',
        'Member Since',
      ],
      rows: [
        for (final u in users)
          [
            u.healthId,
            u.name,
            u.phone,
            u.email,
            '${u.age ?? '-'} / ${u.gender ?? '-'}',
            u.homeClinicName,
            u.totalBookings,
            u.totalQueues,
            u.status.toUpperCase(),
            u.memberSince,
          ],
      ],
    );
  }

  /// Exports Platform Reports & SLA Metrics to PDF.
  static Future<void> exportReports(
    BuildContext context, {
    required PlatformReportEntity report,
    required String timeRange,
    required String tierFilter,
  }) {
    final rows = <List<Object?>>[
      [
        'Patients',
        'Total Patients Served',
        '${report.totalPatients}',
        'N/A',
        '${report.patientsGrowthPercentage >= 0 ? '+' : ''}${report.patientsGrowthPercentage}% vs last cycle',
      ],
      [
        'Clinics',
        'Active Connected Clinics',
        '${report.connectedClinics}',
        'All Onboarded',
        '100% Online',
      ],
      [
        'Wait Time',
        'Average Queue Wait Time',
        '${report.avgWaitMinutes} mins',
        '< 25 mins',
        '-${report.waitReductionMinutes} mins reduction',
      ],
      [
        'Throughput',
        'Completion Rate',
        '${report.completionRatePercentage}%',
        '> 95%',
        report.completionRatePercentage >= 95 ? 'Compliant' : 'Needs Attention',
      ],
      [
        'Doctors',
        'Active Duty Doctors / Slots',
        '${report.activeDoctors} / ${report.totalDoctorSlots}',
        'N/A',
        'Operational',
      ],
      [
        'Revenue',
        'Platform MRR',
        'INR ${report.mrrAmount}',
        'Target',
        '${report.mrrGrowthPercentage >= 0 ? '+' : ''}${report.mrrGrowthPercentage}%',
      ],
      [
        'Tiers',
        'Unlimited / Multi / Solo',
        '${report.unlimitedTierCount} / ${report.multiTierCount} / ${report.soloTierCount}',
        'N/A',
        'Active Subscriptions',
      ],
      for (final c in report.rankedClinics)
        [
          'Clinic Benchmark',
          c.name,
          '${c.appointments} appointments',
          '${c.avgWaitMinutes}m avg wait',
          '${c.rating} ★ (${c.tierPlan.toUpperCase()})',
        ],
    ];

    return exportTable(
      context,
      title: 'QueueFlow - Platform Analytics & SLA Benchmark Report',
      subtitle: 'System Health, Queue Performance & Telemetry Overview',
      fileName: 'queueflow_reports_${dateTag()}.pdf',
      metadata: {
        'Time Range': timeRange.toUpperCase(),
        'Tier Filter': tierFilter.toUpperCase(),
      },
      headers: const [
        'Category',
        'Metric / Facility Description',
        'Recorded Value',
        'Target / SLA',
        'Compliance / Performance',
      ],
      rows: rows,
    );
  }

  /// Exports Platform Revenue & Invoices Ledger to PDF.
  static Future<void> exportRevenueLedger(
    BuildContext context, {
    required List<dynamic> invoices,
    required String totalMrr,
    required String timeframe,
  }) {
    final rows = <List<Object?>>[];
    for (final i in invoices) {
      if (i is PlatformInvoiceEntity) {
        rows.add([
          i.number,
          i.clinicName,
          i.plan,
          'INR ${i.amount}',
          i.dueDate,
          i.date,
          i.status.toUpperCase(),
          i.method,
        ]);
      } else if (i is Map<String, dynamic>) {
        rows.add([
          i['number'] ?? '-',
          i['clinicName'] ?? 'Partner Clinic',
          i['plan'] ?? 'Standard Subscription',
          'INR ${i['amount'] ?? 0}',
          i['dueDate'] ?? '-',
          i['date'] ?? 'Recent',
          (i['status'] ?? 'COMPLETED').toString().toUpperCase(),
          i['method'] ?? 'Razorpay / UPI',
        ]);
      }
    }

    return exportTable(
      context,
      title: 'QueueFlow - Platform Revenue & Billing Ledger',
      subtitle: 'SaaS Subscriptions, Multi-Clinic Settlements & Financial Operations',
      fileName: 'queueflow_revenue_ledger_${dateTag()}.pdf',
      metadata: {
        'Timeframe': timeframe.toUpperCase(),
        'Total MRR': totalMrr,
      },
      headers: const [
        'Invoice #',
        'Clinic / Tenant',
        'Subscription Plan',
        'Amount',
        'Due Date',
        'Issue Date',
        'Status',
        'Payment Method',
      ],
      rows: rows,
    );
  }

  static Future<void> exportInvoices(
    BuildContext context,
    List<PlatformInvoiceEntity> invoices,
  ) {
    return exportTable(
      context,
      title: 'QueueFlow - Invoices Register',
      fileName: 'queueflow_invoices_${dateTag()}.pdf',
      metadata: {'Total Invoices': '${invoices.length}'},
      headers: const [
        'Invoice #',
        'Clinic',
        'Plan',
        'Amount',
        'Due Date',
        'Issue Date',
        'Status',
        'Method',
      ],
      rows: [
        for (final i in invoices)
          [
            i.number,
            i.clinicName,
            i.plan,
            'INR ${i.amount}',
            i.dueDate,
            i.date,
            i.status.toUpperCase(),
            i.method,
          ],
      ],
    );
  }

  static Future<void> exportSubscriptions(
    BuildContext context,
    List<PlatformTenantSubscriptionEntity> subs,
  ) {
    return exportTable(
      context,
      title: 'QueueFlow - Subscriptions Directory',
      fileName: 'queueflow_subscriptions_${dateTag()}.pdf',
      metadata: {'Total Subscriptions': '${subs.length}'},
      headers: const [
        'Clinic',
        'Admin Name',
        'Email',
        'City',
        'Category',
        'Plan',
        'Cycle',
        'MRR',
        'Status',
        'Doctors',
      ],
      rows: [
        for (final s in subs)
          [
            s.clinicName,
            s.adminName,
            s.adminEmail,
            s.city,
            s.category,
            s.planName,
            s.billingCadence,
            'INR ${s.mrrAmount}',
            s.status.toUpperCase(),
            s.practicingDoctors,
          ],
      ],
    );
  }

  static Future<void> exportClinics(
    BuildContext context,
    List<TenantClinicEntity> clinics,
    Map<String, int> appointments,
  ) {
    return exportTable(
      context,
      title: 'QueueFlow - Partner Clinics Directory',
      fileName: 'queueflow_clinics_${dateTag()}.pdf',
      metadata: {'Active Facilities': '${clinics.length}'},
      headers: const [
        'Clinic',
        'Admin',
        'Email',
        'Phone',
        'Address',
        'City',
        'Plan',
        'Status',
        'Appts (Month)',
      ],
      rows: [
        for (final c in clinics)
          [
            c.name,
            c.adminName,
            c.adminEmail,
            c.phone,
            c.address,
            c.city,
            c.planName,
            c.status.toUpperCase(),
            appointments[c.id] ?? 0,
          ],
      ],
    );
  }

  static Future<void> exportDepartments(
    BuildContext context,
    List<DepartmentEntity> depts,
  ) {
    return exportTable(
      context,
      title: 'QueueFlow - Medical Departments Directory',
      fileName: 'queueflow_departments_${dateTag()}.pdf',
      metadata: {'Total Departments': '${depts.length}'},
      headers: const [
        'Name',
        'Code',
        'Description',
        'Avg Consultation',
        'Status',
        'Doctors',
        'Monthly Visits',
        'Clinics',
      ],
      rows: [
        for (final d in depts)
          [
            d.name,
            d.code,
            d.description,
            d.avgConsultationTime,
            d.status.toUpperCase(),
            d.doctorCount,
            d.totalVisits,
            d.assignedClinics.length,
          ],
      ],
    );
  }
}
