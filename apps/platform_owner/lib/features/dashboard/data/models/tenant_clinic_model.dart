import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tenant_clinic_entity.dart';

class TenantClinicModel extends TenantClinicEntity {
  const TenantClinicModel({
    required super.id,
    required super.name,
    super.rating,
    required super.category,
    super.city,
    super.address,
    super.phone,
    super.operatingHours,
    super.monthlyVisits,
    super.practicingDoctors,
    super.doctorLimitText,
    required super.planId,
    super.planName,
    super.billingCadence,
    super.queueStatus,
    super.servingToken,
    super.avgWaitTime,
    required super.adminName,
    required super.adminEmail,
    required super.status,
    super.doctors,
    super.departmentIds,
    super.departments,
  });

  factory TenantClinicModel.fromFirestore(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};
    final plan = d['planId'] ?? 'solo';

    String pName = 'Solo Doctor Plan';
    if (plan == 'multi') pName = 'Multi-Doctor Clinic Plan';
    if (plan == 'enterprise') pName = 'Unlimited Doctors Plan';

    final doctorsList = ((d['doctors'] as List<dynamic>?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map((m) => PracticingDoctorEntity(
              name: m['name'] ?? '',
              specialty: m['specialty'] ?? '',
              room: m['room'] ?? '',
              isAvailable: m['isAvailable'] ?? true,
            ))
        .toList();

    final rawDeptIds = (d['departmentIds'] as List<dynamic>?) ?? [];
    final deptIds = rawDeptIds.map((e) => e.toString()).toList();

    final rawDepts = (d['departments'] as List<dynamic>?) ?? [];
    final deptsList = rawDepts.map((e) => e.toString()).toList();

    return TenantClinicModel(
      id: doc.id,
      name: d['name'] ?? 'Unnamed Clinic',
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      category: d['category'] ?? '',
      city: d['city'] ?? '',
      address: d['address'] ?? '',
      phone: d['phone'] ?? '',
      operatingHours: d['operatingHours'] ?? '',
      monthlyVisits: (d['monthlyVisits'] as num?)?.toInt() ?? 0,
      // Count the real roster; the stored practicingDoctors field was a plan-based placeholder
      practicingDoctors: doctorsList.length,
      doctorLimitText: d['doctorLimitText'] ?? '1 Doctor Limit',
      planId: plan,
      planName: d['planName'] ?? pName,
      billingCadence: d['billingCadence'] ?? 'Monthly Auto-Debit',
      queueStatus: d['queueStatus'] ?? '',
      servingToken: d['servingToken'] ?? '',
      avgWaitTime: d['avgWaitTime'] ?? '',
      adminName: d['adminName'] ?? '',
      adminEmail: d['adminEmail'] ?? '',
      status: (d['status'] ?? 'active').toString().toUpperCase(),
      doctors: doctorsList,
      departmentIds: deptIds,
      departments: deptsList,
    );
  }
}
