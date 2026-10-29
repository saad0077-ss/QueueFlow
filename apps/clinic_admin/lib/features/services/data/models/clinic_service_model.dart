import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_service_entity.dart';

class ClinicServiceModel extends ClinicServiceEntity {
  const ClinicServiceModel({
    required super.id,
    super.clinicId,
    required super.name,
    super.description,
    super.duration,
    super.price,
    super.assignedStaff,
    super.status,
    super.departmentId,
    super.departmentName,
    super.justification,
  });

  factory ClinicServiceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ClinicServiceModel.fromMap(data, doc.id);
  }

  factory ClinicServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return ClinicServiceModel(
      id: id,
      clinicId: map['clinicId'] as String? ?? '',
      name: map['name'] as String? ?? 'Unnamed Service',
      description: map['description'] as String? ?? '',
      duration: (map['duration'] as num?)?.toInt() ?? 20,
      price: (map['price'] as num?)?.toInt() ?? 500,
      assignedStaff:
          (map['assignedStaff'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Dr. Priya'],
      status: map['status'] as String? ?? 'active',
      departmentId: map['departmentId'] as String? ?? 'dept-gen',
      departmentName: map['departmentName'] as String? ?? 'General Medicine',
      justification: map['justification'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'name': name,
      'description': description,
      'duration': duration,
      'price': price,
      'assignedStaff': assignedStaff,
      'status': status,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'justification': justification,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
