import '../entities/billing_invoice_entity.dart';
import '../entities/billing_plan_tier_entity.dart';
import '../entities/clinic_subscription_entity.dart';

/// Contract for fetching and updating clinic plan, billing & invoices.
abstract class ClinicBillingRepository {
  /// Loads the active subscription details and quota usage for the current clinic.
  Future<ClinicSubscriptionEntity> getClinicSubscription();

  /// Loads available subscription plan tiers.
  Future<List<BillingPlanTierEntity>> getPlanTiers();

  /// Loads invoice receipts history for the current clinic.
  Future<List<BillingInvoiceEntity>> getInvoices();

  /// Updates the clinic subscription plan tier.
  Future<void> updatePlan({
    required String planId,
    required String planName,
    required String billingCycle,
    required String amount,
  });

  /// Toggles billing cadence between 'monthly' and 'annual'.
  Future<void> toggleBillingCycle(String newCycle);

  /// Updates GST tax and legal billing contact information.
  Future<void> updateBillingContact(ClinicBillingContactEntity contact);
}
