import '../../domain/entities/clinic_subscription_entity.dart';

class ClinicSubscriptionModel extends ClinicSubscriptionEntity {
  const ClinicSubscriptionModel({
    super.clinicId,
    super.clinicName,
    super.planId,
    super.planName,
    super.billingCycle,
    super.amount,
    super.status,
    super.currentPeriodEnd,
    super.autoRenew,
    super.paymentMethod,
    super.billingContact,
    super.activeDoctors,
    super.doctorLimit,
    super.activeServices,
    super.serviceLimit,
  });

  factory ClinicSubscriptionModel.fromClinicData(
    String id,
    Map<String, dynamic> data, {
    int activeDocs = 1,
    int activeSvcs = 1,
  }) {
    final planId = data['planId'] as String? ?? 'solo';
    final planName = data['planName'] as String? ??
        (planId == 'unlimited' || planId == 'enterprise'
            ? 'Unlimited Doctors Plan'
            : planId == 'multi'
                ? 'Multi-Doctor Clinic Plan'
                : 'Solo Doctor Plan');
    final cadence = data['billingCadence'] as String? ?? 'monthly';
    final status = (data['status'] as String? ?? 'active').toLowerCase();

    final isEnterprise = planId == 'unlimited' || planId == 'enterprise';
    final isMulti = planId == 'multi';
    final docLimit = isEnterprise ? 999 : (isMulti ? 10 : 1);
    final svcLimit = isEnterprise ? 999 : (isMulti ? 10 : 1);

    final pmData = data['paymentMethod'] as Map<String, dynamic>? ?? {};
    final bcData = data['billingContact'] as Map<String, dynamic>? ?? {};

    return ClinicSubscriptionModel(
      clinicId: id,
      clinicName: data['name'] as String? ?? '',
      planId: planId,
      planName: planName,
      billingCycle: cadence.toLowerCase().contains('annual') ? 'annual' : 'monthly',
      amount: data['amount'] as String? ?? (isEnterprise ? '₹6,999' : isMulti ? '₹2,999' : '₹999'),
      status: status,
      currentPeriodEnd: data['currentPeriodEnd'] as String? ?? '',
      autoRenew: data['autoRenew'] as bool? ?? true,
      paymentMethod: ClinicPaymentMethodEntity(
        gateway: pmData['gateway'] as String? ?? 'Razorpay',
        brand: pmData['brand'] as String? ?? 'Razorpay UPI AutoPay',
        upiId: pmData['upiId'] as String? ?? 'priya@okhdfcbank',
        last4: pmData['last4'] as String? ?? 'Auto-Debit',
        exp: pmData['exp'] as String? ?? 'Active e-Mandate',
        holder: pmData['holder'] as String? ?? 'Dr. Priya',
      ),
      billingContact: ClinicBillingContactEntity(
        legalName: bcData['legalName'] as String? ?? (data['name'] as String? ?? ''),
        gstin: bcData['gstin'] as String? ?? '32AAAAA0000A1Z5',
        email: bcData['email'] as String? ?? (data['adminEmail'] as String? ?? ''),
        phone: bcData['phone'] as String? ?? (data['phone'] as String? ?? '+91 484 234 5678'),
        address: bcData['address'] as String? ?? (data['address'] as String? ?? '14 MG Road, Kochi, Kerala 682001'),
      ),
      activeDoctors: activeDocs,
      doctorLimit: docLimit,
      activeServices: activeSvcs,
      serviceLimit: svcLimit,
    );
  }
}
