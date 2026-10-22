import 'package:equatable/equatable.dart';

class DeptServiceRequestEntity extends Equatable {
  final String id;
  final String clinicId;
  final String clinicName;
  final String departmentId;
  final String departmentName;
  final String serviceName;
  final int duration;
  final int suggestedPrice;
  final String description;
  final String requestedBy;
  final String notes;
  final String status;
  final String createdAt;

  const DeptServiceRequestEntity({
    required this.id,
    required this.clinicId,
    required this.clinicName,
    required this.departmentId,
    required this.departmentName,
    required this.serviceName,
    required this.duration,
    required this.suggestedPrice,
    required this.description,
    required this.requestedBy,
    required this.notes,
    required this.status,
    required this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';

  @override
  List<Object?> get props => [
    id,
    clinicId,
    clinicName,
    departmentId,
    departmentName,
    serviceName,
    duration,
    suggestedPrice,
    description,
    requestedBy,
    notes,
    status,
    createdAt,
  ];
}
