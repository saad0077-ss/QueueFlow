import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/dept_expansion_request_entity.dart';

class DeptExpansionRequestModel extends DeptExpansionRequestEntity {
  const DeptExpansionRequestModel({
    required super.id,
    required super.clinicId,
    required super.clinicName,
    required super.departmentIds,
    required super.departmentNames,
    required super.departmentIcons,
    required super.expectedDoctorCount,
    required super.targetDate,
    required super.reason,
    required super.requestedBy,
    required super.status,
    required super.createdAt,
  });

  factory DeptExpansionRequestModel.fromFirestore(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};
    final rawDeptIds = (d['departmentIds'] as List<dynamic>?) ?? [];
    final rawDeptNames = (d['departmentNames'] as List<dynamic>?) ?? [];
    final rawDeptIcons = (d['departmentIcons'] as List<dynamic>?) ?? [];

    return DeptExpansionRequestModel(
      id: doc.id,
      clinicId: d['clinicId'] ?? '',
      clinicName: d['clinicName'] ?? 'Clinic',
      departmentIds: rawDeptIds.map((e) => e.toString()).toList(),
      departmentNames: rawDeptNames.map((e) => e.toString()).toList(),
      departmentIcons: rawDeptIcons.map((e) => e.toString()).toList(),
      expectedDoctorCount: (d['expectedDoctorCount'] as num?)?.toInt() ?? 1,
      targetDate: d['targetDate'] ?? 'Next Month',
      reason: d['reason'] ?? '',
      requestedBy: d['requestedBy'] ?? 'Clinic Administrator',
      status: (d['status'] ?? 'pending').toString().toLowerCase(),
      createdAt: d['createdAt']?.toString() ?? 'Recent',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'clinicName': clinicName,
      'departmentIds': departmentIds,
      'departmentNames': departmentNames,
      'departmentIcons': departmentIcons,
      'expectedDoctorCount': expectedDoctorCount,
      'targetDate': targetDate,
      'reason': reason,
      'requestedBy': requestedBy,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
