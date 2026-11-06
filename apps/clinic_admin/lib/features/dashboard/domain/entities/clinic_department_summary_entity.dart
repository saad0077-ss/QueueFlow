import 'package:equatable/equatable.dart';

/// Live summary of one department assigned to the clinic.
class ClinicDepartmentSummaryEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String icon;
  final String description;
  final String status;
  final int doctorCount;
  final int proceduresCount;
  final int waitingCount;
  final int appointmentCount;

  const ClinicDepartmentSummaryEntity({
    required this.id,
    required this.code,
    required this.name,
    this.icon = '🩺',
    this.description = '',
    this.status = 'active',
    this.doctorCount = 0,
    this.proceduresCount = 0,
    this.waitingCount = 0,
    this.appointmentCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    icon,
    description,
    status,
    doctorCount,
    proceduresCount,
    waitingCount,
    appointmentCount,
  ];
}
