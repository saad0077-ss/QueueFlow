import 'package:equatable/equatable.dart';

class PracticingDoctorEntity extends Equatable {
  final String name;
  final String specialty;
  final String room;
  final bool isAvailable;

  const PracticingDoctorEntity({
    required this.name,
    required this.specialty,
    required this.room,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [name, specialty, room, isAvailable];
}

class TenantClinicEntity extends Equatable {
  final String id;
  final String name;
  final double rating;
  final String category;
  final String city;
  final String address;
  final String phone;
  final String operatingHours;
  final int monthlyVisits;
  final int practicingDoctors;
  final String doctorLimitText;
  final String planId;
  final String planName;
  final String billingCadence;
  final String queueStatus;
  final String servingToken;
  final String avgWaitTime;
  final String adminName;
  final String adminEmail;
  final String status;
  final List<PracticingDoctorEntity> doctors;
  final List<String> departmentIds;
  final List<String> departments;

  const TenantClinicEntity({
    required this.id,
    required this.name,
    this.rating = 0,
    required this.category,
    this.city = '',
    this.address = '',
    this.phone = '',
    this.operatingHours = '',
    this.monthlyVisits = 0,
    this.practicingDoctors = 0,
    this.doctorLimitText = '1 Doctor Limit',
    required this.planId,
    this.planName = 'Solo Doctor Plan',
    this.billingCadence = 'Monthly Auto-Debit',
    this.queueStatus = '',
    this.servingToken = '',
    this.avgWaitTime = '',
    required this.adminName,
    required this.adminEmail,
    required this.status,
    this.doctors = const [],
    this.departmentIds = const [],
    this.departments = const [],
  });

  bool get isInvited => status.toUpperCase() == 'INVITED';
  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isTrial => status.toUpperCase() == 'TRIAL';
  bool get isSuspended => status.toUpperCase() == 'SUSPENDED';

  @override
  List<Object?> get props => [id, name, planId, status, adminEmail, departmentIds, departments];
}
