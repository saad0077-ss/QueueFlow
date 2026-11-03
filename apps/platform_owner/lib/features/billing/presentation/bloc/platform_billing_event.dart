import 'package:equatable/equatable.dart';
import '../../domain/entities/platform_invoice_entity.dart';
import '../../domain/entities/platform_plan_tier_entity.dart';
import '../../domain/entities/platform_tenant_subscription_entity.dart';

abstract class PlatformBillingEvent extends Equatable {
  const PlatformBillingEvent();

  @override
  List<Object?> get props => [];
}

class PlatformBillingStarted extends PlatformBillingEvent {
  const PlatformBillingStarted();
}

class PlatformBillingTabChanged extends PlatformBillingEvent {
  final int activeTab; // 0: Subscriptions, 1: Plan Tiers, 2: Invoice Ledger

  const PlatformBillingTabChanged(this.activeTab);

  @override
  List<Object?> get props => [activeTab];
}

class PlatformBillingSearchChanged extends PlatformBillingEvent {
  final String query;

  const PlatformBillingSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class PlatformBillingInvoiceFilterChanged extends PlatformBillingEvent {
  final String filter; // 'all', 'completed', 'pending', 'cancelled'

  const PlatformBillingInvoiceFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class PlatformBillingSubscriptionsStreamUpdated extends PlatformBillingEvent {
  final List<PlatformTenantSubscriptionEntity> subscriptions;

  const PlatformBillingSubscriptionsStreamUpdated(this.subscriptions);

  @override
  List<Object?> get props => [subscriptions];
}

class PlatformBillingIssueInvoiceSubmitted extends PlatformBillingEvent {
  final String clinicId;
  final String clinicName;
  final String plan;
  final String amount;
  final String dueDate;

  const PlatformBillingIssueInvoiceSubmitted({
    required this.clinicId,
    required this.clinicName,
    required this.plan,
    required this.amount,
    required this.dueDate,
  });

  @override
  List<Object?> get props => [clinicId, clinicName, plan, amount, dueDate];
}

class PlatformBillingSubscriptionUpdated extends PlatformBillingEvent {
  final String clinicId;
  final String planId;
  final String billingCadence;
  final String status;

  const PlatformBillingSubscriptionUpdated({
    required this.clinicId,
    required this.planId,
    required this.billingCadence,
    required this.status,
  });

  @override
  List<Object?> get props => [clinicId, planId, billingCadence, status];
}

class PlatformBillingPlanTierSaved extends PlatformBillingEvent {
  final PlatformPlanTierEntity tier;

  const PlatformBillingPlanTierSaved(this.tier);

  @override
  List<Object?> get props => [tier];
}

class PlatformBillingInvoiceMarkedPaid extends PlatformBillingEvent {
  final PlatformInvoiceEntity invoice;

  const PlatformBillingInvoiceMarkedPaid(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class PlatformBillingFeedbackDismissed extends PlatformBillingEvent {
  const PlatformBillingFeedbackDismissed();
}
