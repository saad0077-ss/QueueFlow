import '../../domain/entities/platform_invoice_entity.dart';

class PlatformInvoiceModel extends PlatformInvoiceEntity {
  const PlatformInvoiceModel({
    required super.id,
    required super.number,
    required super.clinicId,
    required super.clinicName,
    required super.plan,
    required super.amount,
    required super.dueDate,
    required super.date,
    required super.status,
    required super.method,
  });

  factory PlatformInvoiceModel.fromMap(String id, Map<String, dynamic> data) {
    return PlatformInvoiceModel(
      id: id,
      number: data['number'] as String? ?? 'QF-INV-2026-001',
      clinicId: data['clinicId'] as String? ?? 'clinic',
      clinicName: data['clinic'] as String? ?? (data['clinicName'] as String? ?? 'Partner Clinic'),
      plan: data['plan'] as String? ?? 'Solo Doctor Plan',
      amount: data['amount'] as String? ?? '₹999',
      dueDate: data['due'] as String? ?? (data['dueDate'] as String? ?? '15 Oct 2026'),
      date: data['date'] as String? ?? '1 Oct 2026',
      status: data['status'] as String? ?? 'completed',
      method: data['method'] as String? ?? 'Razorpay AutoPay',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'clinicId': clinicId,
      'clinic': clinicName,
      'plan': plan,
      'amount': amount,
      'due': dueDate,
      'date': date,
      'status': status,
      'method': method,
    };
  }
}
