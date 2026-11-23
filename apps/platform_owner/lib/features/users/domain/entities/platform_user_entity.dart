import 'package:equatable/equatable.dart';

class PlatformUserEntity extends Equatable {
  final String id;
  final String name;
  final String initials;
  final String email;
  final String phone;
  final String healthId;
  final String? bloodGroup;
  final String? photoBase64;
  final String? age;
  final String? gender;
  final String? emergencyContact;
  final String homeClinicId;
  final String homeClinicName;
  final String? activeQueueToken;
  final String? activeQueueStatus;
  final String? activeQueueService;
  final String? activeQueueDoctor;
  final String? activeQueueJoinedAt;
  final String memberSince;
  final int totalBookings;
  final int totalQueues;
  final bool isVerified;
  final String status;
  final String userType; // 'platform_user' | 'walk-in'
  final DateTime? createdAt;
  final String? city;
  final String? notes;
  final String? lastActive;

  const PlatformUserEntity({
    required this.id,
    required this.name,
    required this.initials,
    required this.email,
    required this.phone,
    required this.healthId,
    this.bloodGroup,
    this.photoBase64,
    this.age,
    this.gender,
    this.emergencyContact,
    this.homeClinicId = '',
    this.homeClinicName = 'Unassigned',
    this.activeQueueToken,
    this.activeQueueStatus,
    this.activeQueueService,
    this.activeQueueDoctor,
    this.activeQueueJoinedAt,
    this.memberSince = '—',
    this.totalBookings = 0,
    this.totalQueues = 0,
    this.isVerified = true,
    this.status = 'active',
    this.userType = 'platform_user',
    this.createdAt,
    this.city,
    this.notes,
    this.lastActive,
  });

  bool get isWalkIn =>
      userType == 'walk-in' || name.toLowerCase().contains('walk-in');

  @override
  List<Object?> get props => [
    id,
    name,
    initials,
    email,
    phone,
    healthId,
    bloodGroup,
    photoBase64,
    age,
    gender,
    emergencyContact,
    homeClinicId,
    homeClinicName,
    activeQueueToken,
    activeQueueStatus,
    activeQueueService,
    activeQueueDoctor,
    activeQueueJoinedAt,
    memberSince,
    totalBookings,
    totalQueues,
    isVerified,
    status,
    userType,
    createdAt,
    city,
    notes,
    lastActive,
  ];
}
