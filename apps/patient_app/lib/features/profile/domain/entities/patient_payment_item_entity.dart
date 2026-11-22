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
  final String type; // 'queue' or 'appointment'
  final String? token; // e.g. 'SH-GC-001' or 'A-024'
  final String? refundId;
  final String? refundReason;
  final String? refundToAccount;
  final String? refundedAt;

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
    this.type = 'appointment',
    this.token,
    this.refundId,
    this.refundReason,
    this.refundToAccount,
    this.refundedAt,
  });

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isRefunded => status.toLowerCase() == 'refunded';
  bool get isQueueToken => type.toLowerCase() == 'queue';

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
    type,
    token,
    refundId,
    refundReason,
    refundToAccount,
    refundedAt,
  ];
}
