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

  /// Asks the backend to verify the Razorpay payment and activate the plan.
  /// Throws a user-readable [Exception] when the backend rejects the request.
  Future<void> activateSubscription({
    required String planId,
    required String billingCycle,
    required String paymentId,
  });

  /// Updates GST tax and legal billing contact information.
  Future<void> updateBillingContact(ClinicBillingContactEntity contact);
}
