import 'package:flutter/material.dart';
import '../../../../features/appointments/domain/entities/clinic_appointment_entity.dart';
import '../../domain/entities/consultation_audit_item.dart';

/// Calculation engine for Executive Summary Metrics in Clinic Reports.
class ClinicReportsSummaryCalculator {
  static DateTimeRange resolveDateRange(
    String period,
    DateTimeRange? customRange,
  ) {
    if (customRange != null) return customRange;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (period) {
      case 'today':
        return DateTimeRange(start: todayStart, end: todayEnd);
      case 'week':
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 7)),
          end: todayEnd,
        );
      case 'quarter':
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 90)),
          end: todayEnd,
        );
      case 'month':
      default:
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 30)),
          end: todayEnd,
        );
    }
  }

  static List<ClinicAppointmentEntity> filterAppointmentsByDate(
    List<ClinicAppointmentEntity> all,
    DateTimeRange range,
  ) {
    return all.where((a) {
      DateTime? apptDate;
      if (a.dateRaw.isNotEmpty) {
        apptDate = DateTime.tryParse(a.dateRaw);
      }
      apptDate ??= DateTime.now();
      return apptDate.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          apptDate.isBefore(range.end.add(const Duration(seconds: 1)));
    }).toList();
  }

  static List<ConsultationAuditItem> buildRecentConsultations(
    List<ClinicAppointmentEntity> appts,
  ) {
    final completed = appts.where((a) {
      final s = a.status.toLowerCase();
      return s == 'completed' || s == 'confirmed' || s == 'checkedin';
    }).toList();

    return completed.take(15).map((a) {
      return ConsultationAuditItem(
        id: a.id,
        patientName: a.customerName.isNotEmpty ? a.customerName : 'Patient',
        tokenNumber: a.bookingId.isNotEmpty ? a.bookingId : 'T-100',
        doctorName: a.doctor.isNotEmpty ? a.doctor : 'Consulting Doctor',
        serviceName: a.service.isNotEmpty ? a.service : 'General OPD',
        status: a.status.isNotEmpty ? a.status : 'Completed',
        consultationFee: a.servicePrice > 0 ? a.servicePrice : 500.0,
        dateTime: a.dateTime,
      );
    }).toList();
  }
}
