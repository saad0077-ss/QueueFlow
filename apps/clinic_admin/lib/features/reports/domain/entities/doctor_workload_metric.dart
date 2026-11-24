import 'package:equatable/equatable.dart';

/// Performance and workload metric for an individual clinic doctor.
class DoctorWorkloadMetric extends Equatable {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String room;
  final String initials;
  final int visits;
  final int avgSessionMinutes;
  final double rating;
  final int reviewCount;
  final int onTimePercentage;

  const DoctorWorkloadMetric({
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.room,
    required this.initials,
    required this.visits,
    this.avgSessionMinutes = 15,
    this.rating = 4.9,
    this.reviewCount = 0,
    this.onTimePercentage = 98,
  });

  @override
  List<Object?> get props => [
    doctorId,
    doctorName,
    specialty,
    room,
    initials,
    visits,
    avgSessionMinutes,
    rating,
    reviewCount,
    onTimePercentage,
  ];
}
