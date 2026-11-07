import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_doctor_item.dart';

class ClinicDoctorModel extends ClinicDoctorItem {
  const ClinicDoctorModel({
    required super.id,
    required super.name,
    required super.initials,
    required super.title,
    super.specialty,
    super.schedule,
    super.isAvailable,
    super.services,
    super.department,
    super.photoUrl,
    super.rating,
    super.reviewCount,
    super.weeklySchedule,
    super.leaveDates,
    super.slotDuration,
  });

  ClinicDoctorModel withRating({required double rating, required int reviewCount}) => ClinicDoctorModel(
        id: id,
        name: name,
        initials: initials,
        title: title,
        specialty: specialty,
        schedule: schedule,
        isAvailable: isAvailable,
        services: services,
        department: department,
        photoUrl: photoUrl,
        rating: rating,
        reviewCount: reviewCount,
        weeklySchedule: weeklySchedule,
        leaveDates: leaveDates,
        slotDuration: slotDuration,
      );

  factory ClinicDoctorModel.fromFirestore(DocumentSnapshot doc) {
    final map = (doc.data() as Map<String, dynamic>?) ?? {};
    return ClinicDoctorModel.fromMap(map, id: doc.id);
  }

  factory ClinicDoctorModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final name = (map['name'] ?? 'Doctor').toString().trim();
    String initials = 'DR';
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    final rawServices = (map['services'] as List<dynamic>?) ?? [];

    return ClinicDoctorModel(
      id: id ?? map['id'] ?? '',
      name: name,
      initials: (map['initials'] ?? initials).toString(),
      title: (map['title'] ?? map['specialty'] ?? 'Senior Consultant').toString(),
      specialty: (map['specialty'] ?? 'General Medicine').toString(),
      schedule: (map['schedule'] ?? 'Mon–Sat, 9:00 AM – 5:00 PM').toString(),
      isAvailable: map['isAvailable'] as bool? ??
          !const {'offline', 'on_leave', 'on-leave', 'leave', 'off-duty', 'off_duty', 'inactive'}
              .contains((map['status'] ?? '').toString().toLowerCase()),
      weeklySchedule: _parseWeekly(map['weeklySchedule']),
      leaveDates: ((map['leaveDates'] as List<dynamic>?) ?? const []).map((e) => e.toString()).toList(),
      slotDuration: (map['slotDuration'] as num?)?.toInt() ?? 20,
      services: rawServices.map((e) => e.toString()).toList(),
      department: (map['department'] ?? map['specialty'] ?? '').toString(),
      photoUrl: (map['photoUrl'] ?? '').toString(),
    );
  }

  static Map<String, ClinicDoctorDayHours> _parseWeekly(Object? raw) {
    // Same default the clinic admin shows when nothing has been customised.
    if (raw is! Map) {
      return {
        for (final k in const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'])
          k: const ClinicDoctorDayHours(
            enabled: true,
            start: '08:00',
            end: '17:00',
            breakStart: '13:00',
            breakEnd: '14:00',
          ),
      };
    }
    return {
      for (final e in raw.entries)
        if (e.value is Map)
          e.key.toString(): ClinicDoctorDayHours(
            enabled: (e.value as Map)['enabled'] == true,
            start: ((e.value as Map)['start'] ?? '09:00').toString(),
            end: ((e.value as Map)['end'] ?? '17:00').toString(),
            breakStart: ((e.value as Map)['breakStart'] ?? '').toString(),
            breakEnd: ((e.value as Map)['breakEnd'] ?? '').toString(),
          ),
    };
  }

  /// Reads the real doctors a clinic admin added (stored on the clinic
  /// document's `doctors` array), skipping inactive accounts.
  static Future<List<ClinicDoctorModel>> fetchForClinic(
    FirebaseFirestore firestore,
    String clinicId,
  ) async {
    final doc = await firestore.collection('clinics').doc(clinicId).get();
    final raw = (doc.data()?['doctors'] as List<dynamic>?) ?? const [];
    final doctors = <ClinicDoctorModel>[];
    for (var i = 0; i < raw.length; i++) {
      final m = raw[i];
      if (m is! Map) continue;
      final map = Map<String, dynamic>.from(m);
      final account = (map['accountStatus'] ?? 'active').toString().toLowerCase();
      if (account == 'inactive' || account == 'suspended' || account == 'disabled') continue;
      final id = (map['id'] ?? '').toString();
      doctors.add(ClinicDoctorModel.fromMap(map, id: id.isNotEmpty ? id : '$clinicId-doc-$i'));
    }
    if (doctors.isNotEmpty) return doctors;

    // Older clinics may keep doctors in the `staff` collection.
    final snap = await firestore.collection('staff').where('clinicId', isEqualTo: clinicId).get();
    return snap.docs.map(ClinicDoctorModel.fromFirestore).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'initials': initials,
      'title': title,
      'specialty': specialty,
      'schedule': schedule,
      'isAvailable': isAvailable,
      'services': services,
    };
  }
}
