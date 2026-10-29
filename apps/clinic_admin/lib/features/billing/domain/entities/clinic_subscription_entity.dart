import 'package:equatable/equatable.dart';

/// Payment method details for clinic auto-debit.
class ClinicPaymentMethodEntity extends Equatable {
  final String gateway;
  final String brand;
  final String upiId;
  final String last4;
  final String exp;
  final String holder;

  const ClinicPaymentMethodEntity({
    this.gateway = 'Razorpay',
    this.brand = 'Razorpay UPI AutoPay',
    this.upiId = 'priya@okhdfcbank',
    this.last4 = 'Auto-Debit',
    this.exp = 'Active e-Mandate',
    this.holder = 'Dr. Priya',
  });

  @override
  List<Object?> get props => [gateway, brand, upiId, last4, exp, holder];
}

/// Legal and GST tax details of the clinic.
class ClinicBillingContactEntity extends Equatable {
  final String legalName;
  final String gstin;
  final String email;
  final String phone;
  final String address;

  const ClinicBillingContactEntity({
    this.legalName = '',
    this.gstin = '32AAAAA0000A1Z5',
    this.email = '',
    this.phone = '+91 484 234 5678',
    this.address = '14 MG Road, Kochi, Kerala 682001',
  });

  ClinicBillingContactEntity copyWith({
    String? legalName,
    String? gstin,
    String? email,
    String? phone,
    String? address,
  }) {
    return ClinicBillingContactEntity(
      legalName: legalName ?? this.legalName,
      gstin: gstin ?? this.gstin,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [legalName, gstin, email, phone, address];
}

/// Represents the active subscription status and quotas of a clinic.
class ClinicSubscriptionEntity extends Equatable {
  final String clinicId;
  final String clinicName;
  final String planId;
  final String planName;
  final String billingCycle; // 'monthly' | 'annual'
  final String amount;
  final String status;
  final String currentPeriodEnd;
  final bool autoRenew;
  final ClinicPaymentMethodEntity paymentMethod;
  final ClinicBillingContactEntity billingContact;
  final int activeDoctors;
  final int doctorLimit;
  final int activeServices;
  final int serviceLimit;

  const ClinicSubscriptionEntity({
    this.clinicId = '',
    this.clinicName = '',
    this.planId = 'solo',
    this.planName = 'Solo Doctor Plan',
    this.billingCycle = 'monthly',
    this.amount = '₹999',
    this.status = 'active',
    this.currentPeriodEnd = '',
    this.autoRenew = true,
    this.paymentMethod = const ClinicPaymentMethodEntity(),
    this.billingContact = const ClinicBillingContactEntity(),
    this.activeDoctors = 1,
    this.doctorLimit = 1,
    this.activeServices = 1,
    this.serviceLimit = 1,
  });

  bool get isAnnual => billingCycle.toLowerCase() == 'annual';
  bool get isDoctorUnlimited => doctorLimit >= 999;
  bool get isServiceUnlimited => serviceLimit >= 999;

  @override
  List<Object?> get props => [
    clinicId,
    clinicName,
    planId,
    planName,
    billingCycle,
    amount,
    status,
    currentPeriodEnd,
    autoRenew,
    paymentMethod,
    billingContact,
    activeDoctors,
    doctorLimit,
    activeServices,
    serviceLimit,
  ];
}
