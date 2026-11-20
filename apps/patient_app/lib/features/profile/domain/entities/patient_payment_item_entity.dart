import 'package:equatable/equatable.dart';

/// Represents a consultation payment receipt / invoice record.
class PatientPaymentItemEntity extends Equatable {
  final String id;
  final String receiptNo;
  final String bookingId;
  final String clinicId;
  final String clinicName;
  final String department;
  final String service;
  final String doctor;
  final double amount;
  final String status; // 'paid', 'refunded', 'pending'
  final String date;
  final String method; // e.g. 'UPI (Google Pay)', 'Razorpay UPI', 'Credit Card'
  final String transactionId;

  const PatientPaymentItemEntity({
    required this.id,
    required this.receiptNo,
    required this.bookingId,
    required this.clinicId,
    required this.clinicName,
    this.department = 'General Medicine',
    required this.service,
    this.doctor = 'Senior Physician',
    required this.amount,
    this.status = 'paid',
    required this.date,
    this.method = 'UPI (Online)',
    this.transactionId = '',
  });

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isRefunded => status.toLowerCase() == 'refunded';

  @override
  List<Object?> get props => [
    id,
    receiptNo,
    bookingId,
    clinicId,
    clinicName,
    department,
    service,
    doctor,
    amount,
    status,
    date,
    method,
    transactionId,
  ];
}
