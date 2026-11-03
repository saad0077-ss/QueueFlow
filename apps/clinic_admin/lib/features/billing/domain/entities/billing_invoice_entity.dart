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
  ];
}
