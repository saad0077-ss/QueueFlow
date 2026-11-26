import 'package:flutter/material.dart';
import '../../../../core/utils/clinic_pdf_exporter.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import '../../domain/entities/clinic_revenue_summary.dart';
import 'clinic_revenue_formatter.dart';

/// Exports clinic revenue settlements and ledger records as a formatted PDF.
class ClinicRevenueExporter {
  ClinicRevenueExporter._();

  static Future<void> exportLedgerPdf(
    BuildContext context, {
    required ClinicRevenueSummary summary,
    required List<RevenueLedgerEntry> entries,
  }) async {
    final headers = [
      'RECEIPT NO',
      'PATIENT',
      'SERVICE',
      'DOCTOR',
      'DATE',
      'METHOD',
      'STATUS',
      'NET (INR)',
    ];

    final rows = entries.map((e) {
      return [
        e.receiptNo,
        e.patientName,
        e.serviceName,
        e.doctorName,
        e.dateLabel,
        e.method,
        e.status.toUpperCase(),
        ClinicRevenueFormatter.formatInr(e.netAmount),
      ];
    }).toList();

    final clinic = summary.clinicName.isNotEmpty
        ? summary.clinicName
        : 'Clinic Practice';

    await ClinicPdfExporter.exportTable(
      context,
      title: 'Clinic Revenue & Patient Settlements Ledger',
      subtitle: '$clinic • Period: ${summary.period.label}',
      fileName: 'clinic_revenue_${ClinicPdfExporter.dateTag()}.pdf',
      headers: headers,
      rows: rows,
      metadata: {
        'Net Revenue': ClinicRevenueFormatter.formatInr(summary.netRevenue),
        'Collected': ClinicRevenueFormatter.formatInr(summary.grossCollected),
        'Pending': ClinicRevenueFormatter.formatInr(summary.pendingCollections),
        'Refunds': ClinicRevenueFormatter.formatInr(summary.refundedTotal),
      },
    );
  }
}
