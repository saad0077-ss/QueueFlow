import 'package:equatable/equatable.dart';

/// Domain entity representing an appointment in the clinic admin portal.
class ClinicAppointmentEntity extends Equatable {
  final String time;
  final String customer;
  final String service;
  final String doctor;
  final String status;
  final bool isCompleted;

  const ClinicAppointmentEntity({
    required this.time,
    required this.customer,
    required this.service,
    required this.doctor,
    required this.status,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [
        time,
        customer,
        service,
        doctor,
        status,
        isCompleted,
      ];
}
