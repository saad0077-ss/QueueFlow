import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TenantRepository {
  Stream<QuerySnapshot> watchClinics();
  Future<void> seedSampleClinics();
  Future<void> onboardClinic({
    required String name,
    required String category,
    required String planId,
  });
  Future<void> updatePlan(String clinicId, String planId);
  Future<void> toggleStatus(String clinicId, bool currentlyActive);
  Future<void> deleteClinic(String clinicId);
}
