import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/service_department_entity.dart';

/// Department document from the platform admin's `departments` collection.
class ServiceDepartmentModel extends ServiceDepartmentEntity {
  const ServiceDepartmentModel({
    required super.id,
    required super.code,
    required super.name,
    super.icon,
    super.standardServices,
  });

  factory ServiceDepartmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    final rawServices = (d['standardServices'] as List<dynamic>?) ?? [];

    return ServiceDepartmentModel(
      id: doc.id,
      code: d['code'] as String? ?? 'GEN',
      name: d['name'] as String? ?? 'General Specialty',
      icon: d['icon'] as String? ?? '🩺',
      standardServices: rawServices
          .whereType<Map<String, dynamic>>()
          .map(
            (s) => StandardServiceTemplate(
              name: s['name'] as String? ?? '',
              duration: (s['duration'] as num?)?.toInt() ?? 20,
              suggestedPrice: (s['suggestedPrice'] as num?)?.toInt() ?? 500,
              description: s['description'] as String? ?? '',
            ),
          )
          .where((s) => s.name.isNotEmpty)
          .toList(),
    );
  }
}
