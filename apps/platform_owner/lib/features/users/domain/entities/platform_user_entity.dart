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
  final String homeClinicId;
  final String homeClinicName;
  final String? activeQueueToken;
  final String? activeQueueStatus;
  final String memberSince;
  final int totalBookings;
  final bool isVerified;
  final String status;
  final DateTime? createdAt;

  const PlatformUserEntity({
    required this.id,
    required this.name,
    required this.initials,
    required this.email,
    required this.phone,
    required this.healthId,
    this.bloodGroup,
    this.photoBase64,
    this.homeClinicId = '',
    this.homeClinicName = 'General Care',
    this.activeQueueToken,
    this.activeQueueStatus,
    this.memberSince = 'Jan 2026',
    this.totalBookings = 0,
    this.isVerified = true,
    this.status = 'active',
    this.createdAt,
  });

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
        homeClinicId,
        homeClinicName,
        activeQueueToken,
        activeQueueStatus,
        memberSince,
        totalBookings,
        isVerified,
        status,
        createdAt,
      ];
}
