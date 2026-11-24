import 'package:equatable/equatable.dart';
import 'consultation_audit_item.dart';
import 'doctor_workload_metric.dart';
import 'service_revenue_metric.dart';

/// Aggregated clinic analytics & operational report data.
class ClinicReportData extends Equatable {
  final String period; // 'today', 'week', 'month', 'quarter', 'custom'
  final DateTime startDate;
  final DateTime endDate;
  final int totalVisits;
  final int bookedCount;
  final int walkInCount;
  final int completedVisits;
  final int cancelledVisits;
  final double completionRate;
  final double cancellationRate;
  final double totalRevenue;
  final double avgDoctorRating;
  final List<DoctorWorkloadMetric> doctorWorkloads;
  final List<ServiceRevenueMetric> serviceRevenues;
  final List<ConsultationAuditItem> recentConsultations;

  const ClinicReportData({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalVisits,
    required this.bookedCount,
    required this.walkInCount,
    required this.completedVisits,
    required this.cancelledVisits,
    required this.completionRate,
    required this.cancellationRate,
    required this.totalRevenue,
    this.avgDoctorRating = 4.9,
    this.doctorWorkloads = const [],
    this.serviceRevenues = const [],
    this.recentConsultations = const [],
  });

  @override
  List<Object?> get props => [
    period,
    startDate,
    endDate,
    totalVisits,
    bookedCount,
    walkInCount,
    completedVisits,
    cancelledVisits,
    completionRate,
    cancellationRate,
    totalRevenue,
    avgDoctorRating,
    doctorWorkloads,
    serviceRevenues,
    recentConsultations,
  ];
}
