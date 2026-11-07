import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/billing_invoice_entity.dart';

class BillingInvoiceModel extends BillingInvoiceEntity {
  const BillingInvoiceModel({
    required super.id,
    required super.number,
    required super.clinicId,
    required super.clinic,
    required super.plan,
    required super.amount,
    required super.due,
    required super.date,
    required super.status,
    required super.method,
    super.createdAt,
    super.paymentId,
    super.customerName,
    super.customerEmail,
    super.billingCycle,
    super.subtotal,
    super.tax,
    super.paidAt,
    super.startAt,
    super.endAt,
  });

  factory BillingInvoiceModel.fromMap(String id, Map<String, dynamic> data) {
    return BillingInvoiceModel(
      id: id,
      number: data['number'] as String? ?? 'QF-INV-2026-001',
      clinicId: data['clinicId'] as String? ?? '',
      clinic: data['clinic'] as String? ?? '',
      plan: data['plan'] as String? ?? 'Solo Doctor Plan',
      amount: data['amount'] as String? ?? '₹999',
      due: data['due'] as String? ?? '15 Oct 2026',
      date: data['date'] as String? ?? '1 Oct 2026',
      status: data['status'] as String? ?? 'completed',
      method: data['method'] as String? ?? 'Razorpay UPI',
      createdAt: _ts(data['createdAt']),
      paymentId: data['paymentId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerEmail: data['customerEmail'] as String? ?? '',
      billingCycle: data['billingCycle'] as String? ?? '',
      subtotal: data['subtotal'] as num? ?? 0,
      tax: data['tax'] as num? ?? 0,
      paidAt: _ts(data['paidAt']),
      startAt: _ts(data['startAt']),
      endAt: _ts(data['endAt']),
    );
  }

  static DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'clinicId': clinicId,
      'clinic': clinic,
      'plan': plan,
      'amount': amount,
      'due': due,
      'date': date,
      'status': status,
      'method': method,
    };
  }
}
