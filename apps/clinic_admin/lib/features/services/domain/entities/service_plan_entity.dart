import 'package:equatable/equatable.dart';

/// The clinic's subscription plan as shown on the Services page.
/// Clinical services are unlimited on every plan, so there is no quota here.
class ServicePlanEntity extends Equatable {
  final String planName;
  final String planPill;
  final String clinicName;

  const ServicePlanEntity({
    this.planName = 'Solo Doctor Plan',
    this.planPill = 'SOLO DOCTOR PRACTICE',
    this.clinicName = '',
  });

  @override
  List<Object?> get props => [planName, planPill, clinicName];
}
