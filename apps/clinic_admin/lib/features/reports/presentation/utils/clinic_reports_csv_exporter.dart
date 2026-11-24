import 'package:flutter/material.dart';
import '../../../../core/utils/clinic_pdf_exporter.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/entities/clinic_report_data.dart';

/// Exports the Clinic Operational Analytics report as PDF or CSV.
class ClinicReportsCsvExporter {
  static Future<void> exportReportPdf(
    BuildContext context, {
    required ClinicReportData report,
    String clinicName = 'Sunrise Health Clinic',
  }) async {
    final headers = [
      'PATIENT NAME',
      'TOKEN / REF',
      'DOCTOR',
      'SERVICE',
      'STATUS',
      'FEE (INR)',
    ];

    final rows = report.recentConsultations.map((item) {
      return [
        item.patientName,
        item.tokenNumber,
        item.doctorName,
        item.serviceName,
        item.status,
        '₹${item.consultationFee.toStringAsFixed(0)}',
      ];
    }).toList();

    await ClinicPdfExporter.exportTable(
      context,
      title: 'Clinic Operational Analytics & Consultations Register',
      subtitle: '$clinicName • Reporting Period: ${report.period.toUpperCase()}',
      fileName: 'clinic_report_${ClinicPdfExporter.dateTag()}.pdf',
      headers: headers,
      rows: rows,
      metadata: {
        'Total Visits': '${report.totalVisits}',
        'Completed': '${report.completedVisits} (${report.completionRate}%)',
        'No-Shows': '${report.cancelledVisits}',
        'Revenue': '₹${report.totalRevenue.toStringAsFixed(0)}',
      },
    );
  }

  static void exportReportCsv(
    BuildContext context, {
    required ClinicReportData report,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('PATIENT NAME,TOKEN REF,DOCTOR,SERVICE,STATUS,FEE');
    for (final c in report.recentConsultations) {
      buffer.writeln(
        '"${c.patientName}","${c.tokenNumber}","${c.doctorName}","${c.serviceName}","${c.status}","₹${c.consultationFee}"',
      );
    }
    AppSnackBar.showSuccess(
      context,
      message:
          'Exported ${report.recentConsultations.length} records to CSV format.',
    );
  }
}
