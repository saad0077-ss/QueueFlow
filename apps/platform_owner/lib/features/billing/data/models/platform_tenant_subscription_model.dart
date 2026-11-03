import '../../domain/entities/platform_tenant_subscription_entity.dart';

class PlatformTenantSubscriptionModel extends PlatformTenantSubscriptionEntity {
  const PlatformTenantSubscriptionModel({
    required super.clinicId,
    required super.clinicName,
    super.category,
    super.city,
    required super.adminName,
    required super.adminEmail,
    required super.planId,
    super.planName,
    super.billingCadence,
    super.mrrAmount,
    super.status,
    super.practicingDoctors,
    super.doctorLimitText,
  });

  factory PlatformTenantSubscriptionModel.fromMap(String id, Map<String, dynamic> data) {
    final planId = data['planId'] as String? ?? 'solo';
    final isEnterprise = planId == 'unlimited' || planId == 'enterprise';
    final isMulti = planId == 'multi';

    final doctors = (data['doctors'] as List<dynamic>?) ?? [];
    final docCount = doctors.isNotEmpty ? doctors.length : (data['practicingDoctors'] as int? ?? 1);

    final planName = data['planName'] as String? ??
        (isEnterprise ? 'Unlimited Doctors Plan' : (isMulti ? 'Multi-Doctor Clinic Plan' : 'Solo Doctor Plan'));

    final mrr = isEnterprise ? '₹6,999/mo' : (isMulti ? '₹2,999/mo' : '₹999/mo');
    final docLimit = isEnterprise ? 'Unlimited Doctors' : (isMulti ? '10 Doctors Limit' : '1 Doctor Limit');

    return PlatformTenantSubscriptionModel(
      clinicId: id,
      clinicName: data['name'] as String? ?? 'Clinic Practice',
      category: data['category'] as String? ?? 'General & Family Clinic',
      city: data['city'] as String? ?? 'Kochi',
      adminName: data['adminName'] as String? ?? 'Admin',
      adminEmail: data['adminEmail'] as String? ?? '',
      planId: planId,
      planName: planName,
      billingCadence: data['billingCadence'] as String? ?? 'Monthly Auto-Debit',
      mrrAmount: data['amount'] as String? ?? mrr,
      status: (data['status'] as String? ?? 'ACTIVE').toUpperCase(),
      practicingDoctors: docCount,
      doctorLimitText: docLimit,
    );
  }
}
