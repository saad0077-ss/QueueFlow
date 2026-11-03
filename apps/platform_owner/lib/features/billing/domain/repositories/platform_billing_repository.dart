import '../entities/platform_billing_kpis.dart';
import '../entities/platform_invoice_entity.dart';
import '../entities/platform_plan_tier_entity.dart';
import '../entities/platform_tenant_subscription_entity.dart';

abstract class PlatformBillingRepository {
  Future<PlatformBillingKpis> getKpis();

  Stream<List<PlatformTenantSubscriptionEntity>> watchTenantSubscriptions();

  Future<List<PlatformPlanTierEntity>> getPlanTiers();

  Future<List<PlatformInvoiceEntity>> getInvoices();

  Future<void> issueInvoice({
    required String clinicId,
    required String clinicName,
    required String plan,
    required String amount,
    required String dueDate,
  });

  Future<void> updateTenantSubscription({
    required String clinicId,
    required String planId,
    required String billingCadence,
    required String status,
  });

  Future<void> savePlanTier(PlatformPlanTierEntity tier);

  Future<void> markInvoicePaid(String invoiceId);
}
