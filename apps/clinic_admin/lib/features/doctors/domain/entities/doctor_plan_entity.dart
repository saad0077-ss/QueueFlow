import 'package:equatable/equatable.dart';

/// Doctor quota and plan details for the active clinic subscription.
class DoctorPlanEntity extends Equatable {
  final String planName;
  final String planPill;
  final int doctorsLimit;
  final String clinicName;

  const DoctorPlanEntity({
    this.planName = 'Solo Doctor Plan',
    this.planPill = 'SOLO DOCTOR PRACTICE',
    this.doctorsLimit = 1,
    this.clinicName = 'Sunrise Health Clinic',
  });

  bool get isUnlimited => doctorsLimit >= 999;

  @override
  List<Object?> get props => [planName, planPill, doctorsLimit, clinicName];
}
