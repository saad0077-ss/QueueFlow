import 'package:equatable/equatable.dart';

/// Represents the clinic's subscription plan details regarding service quota.
class ServicePlanEntity extends Equatable {
  final String planName;
  final String planPill;
  final int servicesLimit;
  final bool isUnlimited;
  final String clinicName;

  const ServicePlanEntity({
    this.planName = 'Solo Doctor Plan',
    this.planPill = 'SOLO DOCTOR PRACTICE',
    this.servicesLimit = 1,
    this.isUnlimited = false,
    this.clinicName = 'Sunrise Health Clinic',
  });

  @override
  List<Object?> get props => [
    planName,
    planPill,
    servicesLimit,
    isUnlimited,
    clinicName,
  ];
}
