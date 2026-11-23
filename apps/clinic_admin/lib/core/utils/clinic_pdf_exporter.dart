import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/appointments/domain/entities/clinic_appointment_entity.dart';
import '../../features/tickets/domain/entities/clinic_support_ticket_entity.dart';
import '../widgets/app_snack_bar.dart';

/// Unified, reusable PDF exporter for QueueFlow Clinic Administration.
class ClinicPdfExporter {
  static String dateTag() {
    final n = DateTime.now();
    return '${n.year}${n.month.toString().padLeft(2, '0')}${n.day.toString().padLeft(2, '0')}';
  }

  /// Builds a high-contrast, print-ready landscape PDF document with clinic branding and metadata.
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
                    'QueueFlow • Clinic Care Administration',
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
                'QueueFlow Clinic Care Desk • Confidential Medical & Operational Ledger',
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

  /// Generic table export function reused across all Clinic Admin views.
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

  /// Exports Clinic Appointments register to PDF.
  static Future<void> exportAppointments(
    BuildContext context,
    List<ClinicAppointmentEntity> appointments, {
    String? clinicName,
  }) {
    final facility = clinicName ?? 'Clinic';
    return exportTable(
      context,
      title: '$facility - Appointments Register',
      subtitle: 'Scheduled Consultations, Doctor Allocation & Triage Status',
      fileName: 'appointments_report_${dateTag()}.pdf',
      metadata: {'Facility': facility, 'Total Appointments': '${appointments.length}'},
      headers: const [
        'Booking Ref',
        'Patient Name',
        'Phone',
        'Doctor',
        'Service',
        'Date & Time',
        'Status',
        'Fee',
        'Payment',
      ],
      rows: [
        for (final a in appointments)
          [
            a.bookingId,
            a.customerName,
            a.phone,
            a.doctor,
            a.service,
            a.dateTime,
            a.status.toUpperCase(),
            'INR ${a.servicePrice.toStringAsFixed(0)}',
            a.payment.isPaid ? 'PAID (${a.payment.method})' : 'DUE',
          ],
      ],
    );
  }

  /// Exports Clinic Patient Support Tickets to PDF.
  static Future<void> exportTickets(
    BuildContext context,
    List<ClinicSupportTicketEntity> tickets, {
    required String clinicName,
  }) {
    return exportTable(
      context,
      title: '$clinicName - Patient Care & Support Tickets',
      subtitle: 'In-Clinic Queue Delays, Doctor Triage, Billing & Appointment Concerns',
      fileName: 'clinic_support_tickets_${dateTag()}.pdf',
      metadata: {'Facility': clinicName, 'Total Tickets': '${tickets.length}'},
      headers: const [
        'Ticket #',
        'Patient Name',
        'Phone',
        'Token #',
        'Category',
        'Subject',
        'Priority',
        'Status',
        'Assigned Staff',
        'Created',
      ],
      rows: [
        for (final t in tickets)
          [
            t.ticketNumber,
            t.patientName,
            t.patientPhone,
            t.linkedTokenNumber ?? '-',
            t.category.toUpperCase(),
            t.subject,
            t.priority.toUpperCase(),
            t.status.toUpperCase(),
            t.assignedTo ?? 'Unassigned',
            t.createdAt,
          ],
      ],
    );
  }
}
