import 'package:equatable/equatable.dart';

class DeptExpansionRequestEntity extends Equatable {
  final String id;
  final String clinicId;
  final String clinicName;
  final List<String> departmentIds;
  final List<String> departmentNames;
  final List<String> departmentIcons;
  final int expectedDoctorCount;
  final String targetDate;
  final String reason;
  final String requestedBy;
  final String status;
  final String createdAt;

  const DeptExpansionRequestEntity({
    required this.id,
    required this.clinicId,
    required this.clinicName,
    required this.departmentIds,
    required this.departmentNames,
    required this.departmentIcons,
    required this.expectedDoctorCount,
    required this.targetDate,
    required this.reason,
    required this.requestedBy,
    required this.status,
    required this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';

  @override
  List<Object?> get props => [
    id,
    clinicId,
    clinicName,
    departmentIds,
    departmentNames,
    departmentIcons,
    expectedDoctorCount,
    targetDate,
    reason,
    requestedBy,
    status,
    createdAt,
  ];
}
