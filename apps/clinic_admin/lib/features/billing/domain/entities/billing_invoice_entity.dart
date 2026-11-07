import 'package:equatable/equatable.dart';

/// Represents a billing invoice or receipt for a clinic subscription.
class BillingInvoiceEntity extends Equatable {
  final String id;
  final String number;
  final String clinicId;
  final String clinic;
  final String plan;
  final String amount;
  final String due;
  final String date;
  final String status; // 'completed' (Paid), 'pending', 'cancelled' (Overdue)
  final String method;
  final DateTime? createdAt;
  final String paymentId;
  final String customerName;
  final String customerEmail;
  final String billingCycle;
  final num subtotal;
  final num tax;
  final DateTime? paidAt;
  final DateTime? startAt;
  final DateTime? endAt;

  const BillingInvoiceEntity({
    required this.id,
    required this.number,
    required this.clinicId,
    required this.clinic,
    required this.plan,
    required this.amount,
    required this.due,
    required this.date,
    required this.status,
    required this.method,
    this.createdAt,
    this.paymentId = '',
    this.customerName = '',
    this.customerEmail = '',
    this.billingCycle = '',
    this.subtotal = 0,
    this.tax = 0,
    this.paidAt,
    this.startAt,
    this.endAt,
  });

  bool get isPaid => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isOverdue => status.toLowerCase() == 'cancelled';

  @override
  List<Object?> get props => [
    id,
    number,
    clinicId,
    clinic,
    plan,
    amount,
    due,
    date,
    status,
    method,
    createdAt,
    paymentId,
    customerName,
    customerEmail,
    billingCycle,
    subtotal,
    tax,
    paidAt,
    startAt,
    endAt,
  ];
}
