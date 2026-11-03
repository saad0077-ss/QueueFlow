import 'package:equatable/equatable.dart';
import 'doctor_daily_schedule.dart';
import 'doctor_review_entity.dart';

/// Represents a practicing doctor profile with full clinical, schedule, and account details.
class ClinicDoctorProfileEntity extends Equatable {
  final String id;
  final String clinicId;
  final String name;
  final String title;
  final String specialty;
  final String department;
  final String room;
  final String email;
  final String phone;
  final String schedule;
  final String status; // 'available' | 'busy' | 'off-duty'
  final String accountStatus; // 'active' | 'inactive' | 'pending'
  final String qualifications;
  final int experienceYears;
  final String registrationNo;
  final String employmentType; // 'Full-time' | 'Part-time' | 'Visiting Consultant' | 'Contract'
  final int consultationFee;
  final int slotDuration; // in minutes
  final String bio;
  final String photoUrl;
  final String? _initials;
  final String? nowServing;
  final int waitingCount;
  final List<String> services;
  final Map<String, DoctorDailySchedule> weeklySchedule;
  final List<DoctorReviewEntity> reviews;
  final int totalAppointments;
  final int completedAppointments;
  final int upcomingAppointments;

  const ClinicDoctorProfileEntity({
    required this.id,
    this.clinicId = 'sunrise-health',
    required this.name,
    this.title = 'Consulting Physician',
    this.specialty = 'General Medicine',
    String? department,
    this.room = '',
    this.email = '',
    this.phone = '',
    this.schedule = 'Mon–Sat, 9:00 AM – 5:00 PM',
    this.status = 'available',
    this.accountStatus = 'active',
    this.qualifications = '',
    this.experienceYears = 0,
    this.registrationNo = '',
    this.employmentType = '',
    this.consultationFee = 0,
    this.slotDuration = 20,
    this.bio = '',
    this.photoUrl = '',
    String? initials,
    this.nowServing,
    this.waitingCount = 0,
    this.services = const [],
    Map<String, DoctorDailySchedule>? weeklySchedule,
    this.reviews = const [],
    this.totalAppointments = 0,
    this.completedAppointments = 0,
    this.upcomingAppointments = 0,
  })  : department = department ?? specialty,
        weeklySchedule = weeklySchedule ?? const {},
        _initials = initials;

  String get initials => _initials ?? _deriveInitials(name);

  static String _deriveInitials(String fullName) {
    final cleaned = fullName.replaceFirst(RegExp(r'^Dr\.\s*', caseSensitive: false), '').trim();
    if (cleaned.isEmpty) return 'DR';
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  bool get isAvailable => status == 'available';
  bool get isBusy => status == 'busy' || status == 'in-consultation';
  bool get isOffDuty => status == 'off-duty';

  bool get isActiveAccount => accountStatus == 'active';
  bool get isInactiveAccount => accountStatus == 'inactive';
  bool get isPendingAccount => accountStatus == 'pending';

  String get statusLabel {
    if (isBusy) return 'IN CONSULTATION';
    if (isOffDuty) return 'OFF DUTY';
    return 'AVAILABLE';
  }

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold(0.0, (acc, r) => acc + r.rating);
    return sum / reviews.length;
  }

  int get completionRate {
    if (totalAppointments == 0) return 0;
    return ((completedAppointments / totalAppointments) * 100).round();
  }

  ClinicDoctorProfileEntity copyWith({
    String? id,
    String? clinicId,
    String? name,
    String? title,
    String? specialty,
    String? department,
    String? room,
    String? email,
    String? phone,
    String? schedule,
    String? status,
    String? accountStatus,
    String? qualifications,
    int? experienceYears,
    String? registrationNo,
    String? employmentType,
    int? consultationFee,
    int? slotDuration,
    String? bio,
    String? photoUrl,
    String? initials,
    String? nowServing,
    int? waitingCount,
    List<String>? services,
    Map<String, DoctorDailySchedule>? weeklySchedule,
    List<DoctorReviewEntity>? reviews,
    int? totalAppointments,
    int? completedAppointments,
    int? upcomingAppointments,
  }) {
    return ClinicDoctorProfileEntity(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      name: name ?? this.name,
      title: title ?? this.title,
      specialty: specialty ?? this.specialty,
      department: department ?? this.department,
      room: room ?? this.room,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      schedule: schedule ?? this.schedule,
      status: status ?? this.status,
      accountStatus: accountStatus ?? this.accountStatus,
      qualifications: qualifications ?? this.qualifications,
      experienceYears: experienceYears ?? this.experienceYears,
      registrationNo: registrationNo ?? this.registrationNo,
      employmentType: employmentType ?? this.employmentType,
      consultationFee: consultationFee ?? this.consultationFee,
      slotDuration: slotDuration ?? this.slotDuration,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      initials: initials ?? this.initials,
      nowServing: nowServing ?? this.nowServing,
      waitingCount: waitingCount ?? this.waitingCount,
      services: services ?? this.services,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      reviews: reviews ?? this.reviews,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      completedAppointments: completedAppointments ?? this.completedAppointments,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
    );
  }

  @override
  List<Object?> get props => [
    id,
    clinicId,
    name,
    title,
    specialty,
    department,
    room,
    email,
    phone,
    schedule,
    status,
    accountStatus,
    qualifications,
    experienceYears,
    registrationNo,
    employmentType,
    consultationFee,
    slotDuration,
    bio,
    photoUrl,
    _initials,
    nowServing,
    waitingCount,
    services,
    weeklySchedule,
    reviews,
    totalAppointments,
    completedAppointments,
    upcomingAppointments,
  ];
}
