import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/entities/doctor_daily_schedule.dart';
import '../../domain/entities/doctor_review_entity.dart';

class ClinicDoctorProfileModel extends ClinicDoctorProfileEntity {
  const ClinicDoctorProfileModel({
    required super.id,
    super.clinicId,
    required super.name,
    super.title,
    super.specialty,
    super.department,
    super.room,
    super.email,
    super.phone,
    super.schedule,
    super.status,
    super.accountStatus,
    super.qualifications,
    super.experienceYears,
    super.registrationNo,
    super.employmentType,
    super.consultationFee,
    super.slotDuration,
    super.bio,
    super.photoUrl,
    super.initials,
    super.nowServing,
    super.waitingCount,
    super.services,
    super.weeklySchedule,
    super.reviews,
    super.totalAppointments,
    super.completedAppointments,
    super.upcomingAppointments,
  });

  factory ClinicDoctorProfileModel.fromEntity(ClinicDoctorProfileEntity d) {
    return ClinicDoctorProfileModel(
      id: d.id,
      clinicId: d.clinicId,
      name: d.name,
      title: d.title,
      specialty: d.specialty,
      department: d.department,
      room: d.room,
      email: d.email,
      phone: d.phone,
      schedule: d.schedule,
      status: d.status,
      accountStatus: d.accountStatus,
      qualifications: d.qualifications,
      experienceYears: d.experienceYears,
      registrationNo: d.registrationNo,
      employmentType: d.employmentType,
      consultationFee: d.consultationFee,
      slotDuration: d.slotDuration,
      bio: d.bio,
      photoUrl: d.photoUrl,
      initials: d.initials,
      nowServing: d.nowServing,
      waitingCount: d.waitingCount,
      services: d.services,
      weeklySchedule: d.weeklySchedule,
      reviews: d.reviews,
      totalAppointments: d.totalAppointments,
      completedAppointments: d.completedAppointments,
      upcomingAppointments: d.upcomingAppointments,
    );
  }

  factory ClinicDoctorProfileModel.fromMap(
    Map<String, dynamic> map, {
    String defaultClinicId = 'sunrise-health',
  }) {
    final name = map['name']?.toString() ?? 'Dr. Specialist';
    final specialty = map['specialty']?.toString() ?? 'General Medicine';
    final title = map['title']?.toString() ?? 'Consulting Physician';
    final scheduleText = map['schedule']?.toString() ?? 'Mon–Sat, 9:00 AM – 5:00 PM';

    // Parse weekly schedule map if present, else build from scheduleText or defaults
    Map<String, DoctorDailySchedule> weekly;
    if (map['weeklySchedule'] is Map) {
      final rawMap = map['weeklySchedule'] as Map<dynamic, dynamic>;
      weekly = {};
      for (final entry in rawMap.entries) {
        final k = entry.key.toString();
        final v = entry.value is Map ? entry.value as Map<dynamic, dynamic> : {};
        weekly[k] = DoctorDailySchedule(
          dayKey: k,
          dayName: v['dayName']?.toString() ?? _dayName(k),
          shortName: v['shortName']?.toString() ?? _shortDayName(k),
          enabled: v['enabled'] == true,
          start: v['start']?.toString() ?? '09:00',
          end: v['end']?.toString() ?? '17:00',
          breakStart: v['breakStart']?.toString() ?? '13:00',
          breakEnd: v['breakEnd']?.toString() ?? '14:00',
        );
      }
    } else {
      weekly = DoctorDailySchedule.defaultWeekly();
    }

    // Parse reviews
    List<DoctorReviewEntity> reviews = [];
    if (map['reviews'] is List) {
      reviews = (map['reviews'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((r) => DoctorReviewEntity(
                id: r['id']?.toString() ?? 'rev-${DateTime.now().millisecondsSinceEpoch}',
                userName: r['userName']?.toString() ?? 'Verified Patient',
                rating: (r['rating'] as num?)?.toDouble() ?? 5.0,
                date: r['date']?.toString() ?? '',
                service: r['service']?.toString() ?? '',
                comment: r['comment']?.toString() ?? '',
                tags: (r['tags'] as List<dynamic>? ?? []).map((t) => t.toString()).toList(),
              ))
          .toList();
    }

    return ClinicDoctorProfileModel(
      id: map['id']?.toString() ?? 'doc-${DateTime.now().millisecondsSinceEpoch}',
      clinicId: map['clinicId']?.toString() ?? defaultClinicId,
      name: name,
      title: title,
      specialty: specialty,
      department: map['department']?.toString() ?? specialty,
      room: map['room']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      schedule: scheduleText,
      status: map['status']?.toString() ?? 'available',
      accountStatus: map['accountStatus']?.toString() ?? 'active',
      qualifications: map['qualifications']?.toString() ?? '',
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 0,
      registrationNo: map['registrationNo']?.toString() ?? '',
      employmentType: map['employmentType']?.toString() ?? '',
      consultationFee: (map['consultationFee'] as num?)?.toInt() ?? 0,
      slotDuration: (map['slotDuration'] as num?)?.toInt() ?? 20,
      bio: map['bio']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? '',
      initials: map['initials']?.toString(),
      nowServing: map['nowServing']?.toString(),
      waitingCount: (map['waitingCount'] as num?)?.toInt() ?? 0,
      services: (map['services'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      weeklySchedule: weekly,
      reviews: reviews,
      totalAppointments: (map['totalAppointments'] as num?)?.toInt() ?? 0,
      completedAppointments: (map['completedAppointments'] as num?)?.toInt() ?? 0,
      upcomingAppointments: (map['upcomingAppointments'] as num?)?.toInt() ?? 0,
    );
  }

  static String _dayName(String key) {
    switch (key) {
      case 'mon': return 'Monday';
      case 'tue': return 'Tuesday';
      case 'wed': return 'Wednesday';
      case 'thu': return 'Thursday';
      case 'fri': return 'Friday';
      case 'sat': return 'Saturday';
      case 'sun': return 'Sunday';
      default: return key;
    }
  }

  static String _shortDayName(String key) {
    switch (key) {
      case 'mon': return 'Mon';
      case 'tue': return 'Tue';
      case 'wed': return 'Wed';
      case 'thu': return 'Thu';
      case 'fri': return 'Fri';
      case 'sat': return 'Sat';
      case 'sun': return 'Sun';
      default: return key;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clinicId': clinicId,
      'name': name,
      'title': title,
      'specialty': specialty,
      'department': department,
      'room': room,
      'email': email,
      'phone': phone,
      'schedule': schedule,
      'status': status,
      'accountStatus': accountStatus,
      'qualifications': qualifications,
      'experienceYears': experienceYears,
      'registrationNo': registrationNo,
      'employmentType': employmentType,
      'consultationFee': consultationFee,
      'slotDuration': slotDuration,
      'bio': bio,
      'photoUrl': photoUrl,
      'initials': initials,
      'nowServing': nowServing,
      'waitingCount': waitingCount,
      'services': services,
      'weeklySchedule': weeklySchedule.map(
        (k, v) => MapEntry(k, {
          'dayKey': v.dayKey,
          'dayName': v.dayName,
          'shortName': v.shortName,
          'enabled': v.enabled,
          'start': v.start,
          'end': v.end,
          'breakStart': v.breakStart,
          'breakEnd': v.breakEnd,
        }),
      ),
      'reviews': reviews.map((r) => {
        'id': r.id,
        'userName': r.userName,
        'rating': r.rating,
        'date': r.date,
        'service': r.service,
        'comment': r.comment,
        'tags': r.tags,
      }).toList(),
      'totalAppointments': totalAppointments,
      'completedAppointments': completedAppointments,
      'upcomingAppointments': upcomingAppointments,
    };
  }
}
