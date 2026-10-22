import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/dept_service_request_entity.dart';

class DeptServiceRequestModel extends DeptServiceRequestEntity {
  const DeptServiceRequestModel({
    required super.id,
    required super.clinicId,
    required super.clinicName,
    required super.departmentId,
    required super.departmentName,
    required super.serviceName,
    required super.duration,
    required super.suggestedPrice,
    required super.description,
    required super.requestedBy,
    required super.notes,
    required super.status,
    required super.createdAt,
  });

  factory DeptServiceRequestModel.fromFirestore(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};

    return DeptServiceRequestModel(
      id: doc.id,
      clinicId: d['clinicId'] ?? '',
      clinicName: d['clinicName'] ?? 'Clinic',
      departmentId: d['departmentId'] ?? '',
      departmentName: d['departmentName'] ?? 'Specialty',
      serviceName: d['serviceName'] ?? 'Custom Procedure',
      duration: (d['duration'] as num?)?.toInt() ?? 20,
      suggestedPrice: (d['suggestedPrice'] as num?)?.toInt() ?? 500,
      description: d['description'] ?? '',
      requestedBy: d['requestedBy'] ?? 'Clinic Staff',
      notes: d['notes'] ?? '',
      status: (d['status'] ?? 'pending').toString().toLowerCase(),
      createdAt: d['createdAt']?.toString() ?? 'Recent',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'clinicName': clinicName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'serviceName': serviceName,
      'duration': duration,
      'suggestedPrice': suggestedPrice,
      'description': description,
      'requestedBy': requestedBy,
      'notes': notes,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
