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
    final plan = (d['planId'] ?? 'solo').toString();

    String pName = 'Solo Doctor Plan';
    if (plan == 'multi') pName = 'Multi-Doctor Clinic Plan';
    if (plan == 'enterprise') pName = 'Unlimited Doctors Plan';

    final doctorsList = ((d['doctors'] as List<dynamic>?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map((m) => PracticingDoctorEntity(
              name: (m['name'] ?? '').toString(),
              specialty: (m['specialty'] ?? '').toString(),
              room: (m['room'] ?? '').toString(),
              isAvailable: m['isAvailable'] == true,
            ))
        .toList();

    final rawDeptIds = (d['departmentIds'] as List<dynamic>?) ?? [];
    final deptIds = rawDeptIds.map((e) => e.toString()).toList();

    final rawDepts = (d['departments'] as List<dynamic>?) ?? [];
    final deptsList = rawDepts.map((e) => e.toString()).toList();

    return TenantClinicModel(
      id: doc.id,
      name: (d['name'] ?? 'Unnamed Clinic').toString(),
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      category: (d['category'] ?? '').toString(),
      city: (d['city'] ?? '').toString(),
      address: _parseAddress(d),
      phone: (d['phone'] ?? '').toString(),
      operatingHours: _parseHours(d),
      monthlyVisits: (d['monthlyVisits'] as num?)?.toInt() ?? 0,
      practicingDoctors: doctorsList.length,
      doctorLimitText: (d['doctorLimitText'] ?? '1 Doctor Limit').toString(),
      planId: plan,
      planName: (d['planName'] ?? pName).toString(),
      billingCadence: (d['billingCadence'] ?? 'Monthly Auto-Debit').toString(),
      queueStatus: (d['queueStatus'] ?? '').toString(),
      servingToken: (d['servingToken'] ?? '').toString(),
      avgWaitTime: (d['avgWaitTime'] ?? '').toString(),
      adminName: (d['adminName'] ?? '').toString(),
      adminEmail: (d['adminEmail'] ?? '').toString(),
      status: (d['status'] ?? 'active').toString().toUpperCase(),
      doctors: doctorsList,
      departmentIds: deptIds,
      departments: deptsList,
    );
  }

  static String _parseAddress(Map<String, dynamic> d) {
    final addr = d['address'];
    if (addr is String && addr.isNotEmpty) return addr;
    if (d['location'] is Map) {
      final loc = d['location'] as Map;
      final parts = [loc['building'], loc['street'], loc['city']]
          .whereType<String>()
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (parts.isNotEmpty) return parts.join(', ');
    }
    return addr?.toString() ?? '';
  }

  static String _parseHours(Map<String, dynamic> d) {
    if (d['scheduleSummary'] is String && (d['scheduleSummary'] as String).isNotEmpty) {
      return d['scheduleSummary'] as String;
    }
    if (d['openingHours'] is String && (d['openingHours'] as String).isNotEmpty) {
      return d['openingHours'] as String;
    }
    final raw = d['operatingHours'];
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is Map) {
      final mon = raw['monday'];
      final sat = raw['saturday'];
      final sun = raw['sunday'];
      final monOpen = mon is Map && mon['isOpen'] == true;
      final satOpen = sat is Map && sat['isOpen'] == true;
      final sunOpen = sun is Map && sun['isOpen'] == true;
      final monStr = monOpen ? '${mon['openTime']} – ${mon['closeTime']}' : 'Closed';
      if (monOpen && satOpen && !sunOpen) return 'Mon–Sat: $monStr · Sun: Closed';
      if (monOpen && !satOpen && !sunOpen) return 'Mon–Fri: $monStr · Sun: Closed';
      return 'Standard OPD Schedule';
    }
    return 'Mon–Sat: 9:00 AM – 8:00 PM';
  }
}
