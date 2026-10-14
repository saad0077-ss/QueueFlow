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
  });

  factory TenantClinicModel.fromFirestore(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};
    final plan = d['planId'] ?? 'solo';

    String pName = 'Solo Doctor Plan';
    if (plan == 'multi') pName = 'Multi-Doctor Clinic Plan';
    if (plan == 'enterprise') pName = 'Unlimited Doctors Plan';

    final rawDoctors = (d['doctors'] as List<dynamic>?) ?? [];
    final doctorsList = rawDoctors.map((docData) {
      final m = docData as Map<String, dynamic>;
      return PracticingDoctorEntity(
        name: m['name'] ?? 'Dr. Specialist',
        specialty: m['specialty'] ?? 'General Medicine',
        room: m['room'] ?? 'Consultation Suite',
        isAvailable: m['isAvailable'] ?? true,
      );
    }).toList();

    return TenantClinicModel(
      id: doc.id,
      name: d['name'] ?? 'Sunrise Health Clinic',
      rating: (d['rating'] as num?)?.toDouble() ?? 4.8,
      category: d['category'] ?? 'General & Family Clinic',
      city: d['city'] ?? 'Kochi',
      address: d['address'] ?? 'Panampilly Nagar, Kochi, Kerala',
      phone: d['phone'] ?? '+91 484 987 6543',
      operatingHours: d['operatingHours'] ?? 'Mon–Sat, 9:00 AM – 8:00 PM',
      monthlyVisits: d['monthlyVisits'] ?? 256,
      practicingDoctors: d['practicingDoctors'] ?? 1,
      doctorLimitText: d['doctorLimitText'] ?? '1 Doctor Limit',
      planId: plan,
      planName: d['planName'] ?? pName,
      billingCadence: d['billingCadence'] ?? 'Monthly Auto-Debit',
      queueStatus: d['queueStatus'] ?? 'Queue Open (3 in line)',
      servingToken: d['servingToken'] ?? 'A-021',
      avgWaitTime: d['avgWaitTime'] ?? '15m wait',
      adminName: d['adminName'] ?? 'Dr. Priya',
      adminEmail: d['adminEmail'] ?? 'priya@sunrisehealth.com',
      status: (d['status'] ?? 'active').toString().toUpperCase(),
      doctors: doctorsList.isNotEmpty
          ? doctorsList
          : [
              PracticingDoctorEntity(
                name: d['adminName'] ?? 'Dr. Priya',
                specialty: d['category'] ?? 'General & Family Medicine',
                room: 'Room 1 (Consultation)',
                isAvailable: true,
              ),
            ],
    );
  }
}
