import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tenant_clinic_entity.dart';

class TenantClinicModel extends TenantClinicEntity {
  const TenantClinicModel({
    required super.id,
    required super.name,
    required super.category,
    required super.planId,
    required super.status,
  });

  factory TenantClinicModel.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TenantClinicModel(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Clinic',
      category: data['category'] ?? 'General Medicine',
      planId: data['planId'] ?? 'solo',
      status: data['status'] ?? 'active',
    );
  }
}
