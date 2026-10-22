import 'package:equatable/equatable.dart';

import 'standard_service_entity.dart';

class DepartmentEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String icon;
  final String color;
  final String description;
  final String avgConsultationTime;
  final String status;
  final int doctorCount;
  final int totalVisits;
  final List<String> assignedClinics;
  final List<StandardServiceEntity> standardServices;

  const DepartmentEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.icon,
    this.color = '#2563EB',
    required this.description,
    this.avgConsultationTime = '20 mins',
    this.status = 'active',
    this.doctorCount = 1,
    this.totalVisits = 0,
    this.assignedClinics = const [],
    this.standardServices = const [],
  });

  bool get isActive => status.toLowerCase() == 'active';

  DepartmentEntity copyWith({
    String? name,
    String? code,
    String? icon,
    String? color,
    String? description,
    String? avgConsultationTime,
    String? status,
    int? doctorCount,
    int? totalVisits,
    List<String>? assignedClinics,
    List<StandardServiceEntity>? standardServices,
  }) {
    return DepartmentEntity(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      avgConsultationTime: avgConsultationTime ?? this.avgConsultationTime,
      status: status ?? this.status,
      doctorCount: doctorCount ?? this.doctorCount,
      totalVisits: totalVisits ?? this.totalVisits,
      assignedClinics: assignedClinics ?? this.assignedClinics,
      standardServices: standardServices ?? this.standardServices,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    icon,
    color,
    description,
    avgConsultationTime,
    status,
    doctorCount,
    totalVisits,
    assignedClinics,
    standardServices,
  ];
}
