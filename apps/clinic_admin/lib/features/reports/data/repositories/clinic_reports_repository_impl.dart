import 'package:flutter/material.dart';
import '../../../../features/appointments/data/repositories/clinic_appointments_repository_impl.dart';
import '../../../../features/appointments/domain/entities/clinic_appointment_entity.dart';
import '../../../../features/appointments/domain/repositories/clinic_appointments_repository.dart';
import '../../../../features/doctors/data/repositories/clinic_doctors_repository_impl.dart';
import '../../../../features/doctors/domain/entities/clinic_doctor_profile_entity.dart';
import '../../../../features/doctors/domain/repositories/clinic_doctors_repository.dart';
import '../../../../features/services/data/repositories/clinic_services_repository_impl.dart';
import '../../../../features/services/domain/entities/clinic_service_entity.dart';
import '../../../../features/services/domain/repositories/clinic_services_repository.dart';
import '../calculators/clinic_reports_summary_calculator.dart';
import '../calculators/doctor_workload_calculator.dart';
import '../calculators/service_revenue_calculator.dart';
import '../../domain/entities/clinic_report_data.dart';
import '../../domain/repositories/clinic_reports_repository.dart';

class ClinicReportsRepositoryImpl implements ClinicReportsRepository {
  final ClinicAppointmentsRepository _appointmentsRepo;
  final ClinicDoctorsRepository _doctorsRepo;
  final ClinicServicesRepository _servicesRepo;

  ClinicReportsRepositoryImpl({
    ClinicAppointmentsRepository? appointmentsRepo,
    ClinicDoctorsRepository? doctorsRepo,
    ClinicServicesRepository? servicesRepo,
  }) : _appointmentsRepo = appointmentsRepo ?? ClinicAppointmentsRepositoryImpl(),
       _doctorsRepo = doctorsRepo ?? ClinicDoctorsRepositoryImpl(),
       _servicesRepo = servicesRepo ?? ClinicServicesRepositoryImpl();

  @override
  Future<ClinicReportData> getReport({
    String period = 'month',
    DateTimeRange? customRange,
  }) async {
    final range = ClinicReportsSummaryCalculator.resolveDateRange(period, customRange);

    final apptsList = await _appointmentsRepo
        .watchAppointments()
        .first
        .timeout(
          const Duration(seconds: 2),
          onTimeout: () => <ClinicAppointmentEntity>[],
        )
        .catchError((_) => <ClinicAppointmentEntity>[]);
    final doctorsList = await _doctorsRepo
        .watchDoctors()
        .first
        .timeout(
          const Duration(seconds: 2),
          onTimeout: () => <ClinicDoctorProfileEntity>[],
        )
        .catchError((_) => <ClinicDoctorProfileEntity>[]);
    final servicesList = await _servicesRepo
        .watchServices()
        .first
        .timeout(
          const Duration(seconds: 2),
          onTimeout: () => <ClinicServiceEntity>[],
        )
        .catchError((_) => <ClinicServiceEntity>[]);

    final filtered = ClinicReportsSummaryCalculator.filterAppointmentsByDate(apptsList, range);
    final totalVisits = filtered.length;
    final bookedCount = filtered.where((a) => a.type.toLowerCase() != 'walk-in').length;
    final walkInCount = filtered.where((a) => a.type.toLowerCase() == 'walk-in').length;
    final completedVisits = filtered.where((a) => a.status.toLowerCase() == 'completed').length;
    final cancelledVisits = filtered.where((a) => a.status.toLowerCase() == 'cancelled').length;

    final compRate = totalVisits > 0 ? (completedVisits / totalVisits) * 100 : 0.0;
    final cancelRate = totalVisits > 0 ? (cancelledVisits / totalVisits) * 100 : 0.0;

    double rev = 0.0;
    for (final a in filtered) {
      if (a.status.toLowerCase() == 'completed' || a.status.toLowerCase() == 'confirmed') {
        rev += a.servicePrice > 0 ? a.servicePrice : (a.payment.amount > 0 ? a.payment.amount : 500.0);
      }
    }

    final docMetrics = DoctorWorkloadCalculator.calculateWorkload(
      doctors: doctorsList,
      appointments: filtered,
    );

    final svcMetrics = ServiceRevenueCalculator.calculateServiceMetrics(
      services: servicesList,
      appointments: filtered,
    );

    final recent = ClinicReportsSummaryCalculator.buildRecentConsultations(filtered);

    return ClinicReportData(
      period: period,
      startDate: range.start,
      endDate: range.end,
      totalVisits: totalVisits,
      bookedCount: bookedCount,
      walkInCount: walkInCount,
      completedVisits: completedVisits,
      cancelledVisits: cancelledVisits,
      completionRate: double.parse(compRate.toStringAsFixed(1)),
      cancellationRate: double.parse(cancelRate.toStringAsFixed(1)),
      totalRevenue: rev,
      doctorWorkloads: docMetrics,
      serviceRevenues: svcMetrics,
      recentConsultations: recent,
    );
  }

  @override
  Stream<ClinicReportData> watchReport({
    String period = 'month',
    DateTimeRange? customRange,
  }) async* {
    yield await getReport(period: period, customRange: customRange);
  }
}
