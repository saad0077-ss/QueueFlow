import 'package:equatable/equatable.dart';

class PlatformTenantSubscriptionEntity extends Equatable {
  final String clinicId;
  final String clinicName;
  final String category;
  final String city;
  final String adminName;
  final String adminEmail;
  final String planId;
  final String planName;
  final String billingCadence;
  final String mrrAmount;
  final String status;
  final int practicingDoctors;
  final String doctorLimitText;

  const PlatformTenantSubscriptionEntity({
    required this.clinicId,
    required this.clinicName,
    this.category = 'General & Family Clinic',
    this.city = 'Kochi',
    required this.adminName,
    required this.adminEmail,
    required this.planId,
    this.planName = 'Solo Doctor Plan',
    this.billingCadence = 'Monthly Auto-Debit',
    this.mrrAmount = '₹999/mo',
    this.status = 'ACTIVE',
    this.practicingDoctors = 1,
    this.doctorLimitText = '1 Doctor Limit',
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isTrial => status.toUpperCase() == 'TRIAL';
  bool get isSuspended => status.toUpperCase() == 'SUSPENDED';
  bool get isPastDue => status.toUpperCase() == 'PAST_DUE' || status.toUpperCase() == 'OVERDUE';

  @override
  List<Object?> get props => [
    clinicId,
    clinicName,
    category,
    city,
    adminName,
    adminEmail,
    planId,
    planName,
    billingCadence,
    mrrAmount,
    status,
    practicingDoctors,
    doctorLimitText,
  ];
}
