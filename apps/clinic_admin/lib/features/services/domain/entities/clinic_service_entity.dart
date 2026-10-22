import 'package:equatable/equatable.dart';

/// Represents a clinical service offered by the clinic.
class ClinicServiceEntity extends Equatable {
  final String id;
  final String clinicId;
  final String name;
  final String description;
  final int duration;
  final int price;
  final List<String> assignedStaff;
  final String status;
  final String departmentId;
  final String departmentName;
  final String justification;

  const ClinicServiceEntity({
    required this.id,
    this.clinicId = 'sunrise-health',
    required this.name,
    this.description = '',
    this.duration = 20,
    this.price = 500,
    this.assignedStaff = const ['Dr. Priya'],
    this.status = 'active',
    this.departmentId = 'dept-gen',
    this.departmentName = 'General Medicine',
    this.justification = '',
  });

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending_approval';
  bool get isRejected => status == 'rejected';

  ClinicServiceEntity copyWith({
    String? id,
    String? clinicId,
    String? name,
    String? description,
    int? duration,
    int? price,
    List<String>? assignedStaff,
    String? status,
    String? departmentId,
    String? departmentName,
    String? justification,
  }) {
    return ClinicServiceEntity(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      status: status ?? this.status,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      justification: justification ?? this.justification,
    );
  }

  @override
  List<Object?> get props => [
    id,
    clinicId,
    name,
    description,
    duration,
    price,
    assignedStaff,
    status,
    departmentId,
    departmentName,
    justification,
  ];
}
