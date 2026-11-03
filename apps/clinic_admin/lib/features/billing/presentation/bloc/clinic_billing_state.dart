import 'package:equatable/equatable.dart';
import '../../domain/entities/billing_invoice_entity.dart';
import '../../domain/entities/billing_plan_tier_entity.dart';
import '../../domain/entities/clinic_subscription_entity.dart';

enum ClinicBillingStatus { initial, loading, success, failure }

class ClinicBillingState extends Equatable {
  final ClinicBillingStatus status;
  final ClinicSubscriptionEntity? subscription;
  final List<BillingPlanTierEntity> tiers;
  final List<BillingInvoiceEntity> invoices;
  final String activeCadence; // 'monthly' | 'annual'
  final bool isSubmitting;
  final String? feedbackMessage;
  final bool isError;

  const ClinicBillingState({
    this.status = ClinicBillingStatus.initial,
    this.subscription,
    this.tiers = const [],
    this.invoices = const [],
    this.activeCadence = 'monthly',
    this.isSubmitting = false,
    this.feedbackMessage,
    this.isError = false,
  });

  bool get isLoading => status == ClinicBillingStatus.loading;

  BillingPlanTierEntity? get currentTier {
    if (subscription == null || tiers.isEmpty) return null;
    final planId = subscription!.planId.toLowerCase();
    return tiers.firstWhere(
      (t) => t.id.toLowerCase() == planId || subscription!.planName.toLowerCase().contains(t.id),
      orElse: () => tiers.first,
    );
  }

  ClinicBillingState copyWith({
    ClinicBillingStatus? status,
    ClinicSubscriptionEntity? subscription,
    List<BillingPlanTierEntity>? tiers,
    List<BillingInvoiceEntity>? invoices,
    String? activeCadence,
    bool? isSubmitting,
    String? feedbackMessage,
    bool? isError,
  }) {
    return ClinicBillingState(
      status: status ?? this.status,
      subscription: subscription ?? this.subscription,
      tiers: tiers ?? this.tiers,
      invoices: invoices ?? this.invoices,
      activeCadence: activeCadence ?? this.activeCadence,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      feedbackMessage: feedbackMessage,
      isError: isError ?? false,
    );
  }

  @override
  List<Object?> get props => [
    status,
    subscription,
    tiers,
    invoices,
    activeCadence,
    isSubmitting,
    feedbackMessage,
    isError,
  ];
}
