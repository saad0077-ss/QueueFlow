import 'package:equatable/equatable.dart';
import '../../domain/entities/platform_billing_kpis.dart';
import '../../domain/entities/platform_invoice_entity.dart';
import '../../domain/entities/platform_plan_tier_entity.dart';
import '../../domain/entities/platform_tenant_subscription_entity.dart';

enum PlatformBillingStatus { initial, loading, success, failure }

class PlatformBillingState extends Equatable {
  final PlatformBillingStatus status;
  final PlatformBillingKpis kpis;
  final List<PlatformTenantSubscriptionEntity> subscriptions;
  final List<PlatformPlanTierEntity> tiers;
  final List<PlatformInvoiceEntity> invoices;
  final int activeTab; // 0: Subscriptions, 1: Plan Tiers, 2: Invoice Ledger
  final String searchQuery;
  final String invoiceFilter; // 'all', 'completed', 'pending', 'cancelled'
  final bool isSubmitting;
  final String? feedbackMessage;
  final bool isError;

  const PlatformBillingState({
    this.status = PlatformBillingStatus.initial,
    this.kpis = const PlatformBillingKpis(),
    this.subscriptions = const [],
    this.tiers = const [],
    this.invoices = const [],
    this.activeTab = 0,
    this.searchQuery = '',
    this.invoiceFilter = 'all',
    this.isSubmitting = false,
    this.feedbackMessage,
    this.isError = false,
  });

  bool get isLoading => status == PlatformBillingStatus.loading;

  List<PlatformTenantSubscriptionEntity> get filteredSubscriptions {
    if (searchQuery.trim().isEmpty) return subscriptions;
    final q = searchQuery.toLowerCase();
    return subscriptions.where((s) {
      return s.clinicName.toLowerCase().contains(q) ||
          s.planName.toLowerCase().contains(q) ||
          s.adminName.toLowerCase().contains(q) ||
          s.adminEmail.toLowerCase().contains(q);
    }).toList();
  }

  List<PlatformInvoiceEntity> get filteredInvoices {
    if (invoiceFilter == 'all') return invoices;
    return invoices.where((i) => i.status.toLowerCase() == invoiceFilter.toLowerCase()).toList();
  }

  PlatformBillingState copyWith({
    PlatformBillingStatus? status,
    PlatformBillingKpis? kpis,
    List<PlatformTenantSubscriptionEntity>? subscriptions,
    List<PlatformPlanTierEntity>? tiers,
    List<PlatformInvoiceEntity>? invoices,
    int? activeTab,
    String? searchQuery,
    String? invoiceFilter,
    bool? isSubmitting,
    String? feedbackMessage,
    bool? isError,
  }) {
    return PlatformBillingState(
      status: status ?? this.status,
      kpis: kpis ?? this.kpis,
      subscriptions: subscriptions ?? this.subscriptions,
      tiers: tiers ?? this.tiers,
      invoices: invoices ?? this.invoices,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      invoiceFilter: invoiceFilter ?? this.invoiceFilter,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      feedbackMessage: feedbackMessage,
      isError: isError ?? false,
    );
  }

  @override
  List<Object?> get props => [
    status,
    kpis,
    subscriptions,
    tiers,
    invoices,
    activeTab,
    searchQuery,
    invoiceFilter,
    isSubmitting,
    feedbackMessage,
    isError,
  ];
}
