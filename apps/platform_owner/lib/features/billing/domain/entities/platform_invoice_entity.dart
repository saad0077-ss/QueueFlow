import 'package:equatable/equatable.dart';

class PlatformInvoiceEntity extends Equatable {
  final String id;
  final String number;
  final String clinicId;
  final String clinicName;
  final String plan;
  final String amount;
  final String dueDate;
  final String date;
  final String status; // 'completed', 'pending', 'cancelled' (Overdue)
  final String method;

  const PlatformInvoiceEntity({
    required this.id,
    required this.number,
    required this.clinicId,
    required this.clinicName,
    required this.plan,
    required this.amount,
    required this.dueDate,
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
    clinicName,
    plan,
    amount,
    dueDate,
    date,
    status,
    method,
  ];
}
