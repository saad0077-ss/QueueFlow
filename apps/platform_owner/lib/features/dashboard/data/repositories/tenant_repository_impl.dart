import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/tenant_repository.dart';

class TenantRepositoryImpl implements TenantRepository {
  final FirebaseFirestore _firestore;

  TenantRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<QuerySnapshot> watchClinics() {
    return _firestore.collection('clinics').snapshots();
  }

  @override
  Future<void> seedSampleClinics() async {
    const sampleClinics = [
      {
        'name': 'Metro Health Primary Care',
        'category': 'General Medicine',
        'planId': 'multi',
        'status': 'active',
      },
      {
        'name': 'Apex Dental Studio',
        'category': 'Dental',
        'planId': 'solo',
        'status': 'active',
      },
      {
        'name': 'CareFirst Dermatology & Laser',
        'category': 'Dermatology',
        'planId': 'enterprise',
        'status': 'active',
      },
    ];

    for (final clinic in sampleClinics) {
      await _firestore.collection('clinics').add({
        ...clinic,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> onboardClinic({
    required String name,
    required String category,
    required String planId,
  }) async {
    await _firestore.collection('clinics').add({
      'name': name.trim(),
      'category': category,
      'planId': planId,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updatePlan(String clinicId, String planId) async {
    await _firestore.collection('clinics').doc(clinicId).update({
      'planId': planId,
    });
  }

  @override
  Future<void> toggleStatus(String clinicId, bool currentlyActive) async {
    await _firestore.collection('clinics').doc(clinicId).update({
      'status': currentlyActive ? 'suspended' : 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteClinic(String clinicId) async {
    await _firestore.collection('clinics').doc(clinicId).delete();
  }
}
