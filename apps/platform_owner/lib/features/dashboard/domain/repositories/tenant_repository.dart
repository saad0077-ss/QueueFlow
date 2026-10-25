import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardClinicResult {
  final String inviteUrl;
  final bool emailDelivered;
  final String? emailFeedback;

  const OnboardClinicResult({
    required this.inviteUrl,
    required this.emailDelivered,
    this.emailFeedback,
  });
}

abstract class TenantRepository {
  Stream<QuerySnapshot> watchClinics();

  /// Ticket counts for the current calendar month, keyed by clinicId
  Stream<Map<String, int>> watchMonthlyAppointmentCounts();
  Future<void> seedSampleClinics();
  Future<void> purgeDummyClinics();
  Future<OnboardClinicResult> onboardClinic({
    required String name,
    required String address,
    required String adminName,
    required String adminEmail,
    required String planId,
    List<String> departmentIds = const [],
    List<String> departmentNames = const [],
  });
  Future<void> updateClinic({
    required String clinicId,
    required String name,
    required String address,
    required String city,
    required String adminName,
    required String planId,
    String? phone,
    List<String> departmentIds = const [],
    List<String> departmentNames = const [],
  });
  Future<void> updateSubscription({
    required String clinicId,
    required String planId,
    required String billingCadence,
    required String status,
  });
  Future<void> toggleStatus(String clinicId, bool currentlyActive);
  Future<void> deleteClinic(String clinicId, {String? adminEmail});
  Future<OnboardClinicResult> resendInvite({
    required String clinicId,
    required String clinicName,
    required String adminName,
    required String adminEmail,
  });
}
