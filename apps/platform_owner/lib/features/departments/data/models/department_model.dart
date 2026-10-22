import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/department_entity.dart';
import 'standard_service_model.dart';

class DepartmentModel extends DepartmentEntity {
  const DepartmentModel({
    required super.id,
    required super.name,
    required super.code,
    required super.icon,
    super.color = '#2563EB',
    required super.description,
    super.avgConsultationTime = '20 mins',
    super.status = 'active',
    super.doctorCount = 1,
    super.totalVisits = 0,
    super.assignedClinics = const [],
    super.standardServices = const [],
  });

  factory DepartmentModel.fromFirestore(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};
    final rawServices = (d['standardServices'] as List<dynamic>?) ?? [];
    final services = rawServices.map((s) => StandardServiceModel.fromMap(s as Map<String, dynamic>)).toList();

    final rawClinics = (d['assignedClinics'] as List<dynamic>?) ?? [];
    final clinics = rawClinics.map((e) => e.toString()).toList();

    return DepartmentModel(
      id: doc.id,
      name: d['name'] ?? 'General Specialty',
      code: d['code'] ?? 'GEN',
      icon: d['icon'] ?? '🩺',
      color: d['color'] ?? '#2563EB',
      description: d['description'] ?? '',
      avgConsultationTime: d['avgConsultationTime'] ?? '20 mins',
      status: (d['status'] ?? 'active').toString().toLowerCase(),
      doctorCount: (d['doctorCount'] as num?)?.toInt() ?? 1,
      totalVisits: (d['totalVisits'] as num?)?.toInt() ?? 0,
      assignedClinics: clinics,
      standardServices: services,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'icon': icon,
      'color': color,
      'description': description,
      'avgConsultationTime': avgConsultationTime,
      'status': status,
      'doctorCount': doctorCount,
      'totalVisits': totalVisits,
      'assignedClinics': assignedClinics,
      'standardServices': standardServices.map((s) => (s as StandardServiceModel).toMap()).toList(),
    };
  }
}
