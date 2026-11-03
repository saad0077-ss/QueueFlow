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
    );
  }

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
