import 'package:equatable/equatable.dart';
import '../../domain/entities/billing_plan_tier_entity.dart';
import '../../domain/entities/clinic_subscription_entity.dart';

abstract class ClinicBillingEvent extends Equatable {
  const ClinicBillingEvent();

  @override
  List<Object?> get props => [];
}

class ClinicBillingStarted extends ClinicBillingEvent {
  const ClinicBillingStarted();
}

class ClinicBillingCadenceToggled extends ClinicBillingEvent {
  final String newCadence; // 'monthly' | 'annual'

  const ClinicBillingCadenceToggled(this.newCadence);

  @override
  List<Object?> get props => [newCadence];
}

class ClinicBillingPlanChangeRequested extends ClinicBillingEvent {
  final BillingPlanTierEntity targetTier;
  final String billingCadence;

  const ClinicBillingPlanChangeRequested({
    required this.targetTier,
    required this.billingCadence,
  });

  @override
  List<Object?> get props => [targetTier, billingCadence];
}

class ClinicBillingContactUpdated extends ClinicBillingEvent {
  final ClinicBillingContactEntity contact;

  const ClinicBillingContactUpdated(this.contact);

  @override
  List<Object?> get props => [contact];
}

class ClinicBillingInvoicesRefreshed extends ClinicBillingEvent {
  const ClinicBillingInvoicesRefreshed();
}

class ClinicBillingFeedbackDismissed extends ClinicBillingEvent {
  const ClinicBillingFeedbackDismissed();
}
