import 'package:equatable/equatable.dart';

/// Payment metadata for an appointment.
class AppointmentPaymentEntity extends Equatable {
  final String status; // 'paid', 'pending', 'refunded'
  final double amount;
  final String currency;
  final String gateway;
  final String method;
  final String paymentId;
  final String orderId;
  final String receiptNo;
  final String paidAt;
  final double? refundAmount;
  final String? refundId;
  final String? refundedAt;
  final String? refundNote;
  final String? refundStatus; // 'pending', 'processed', 'failed'

  const AppointmentPaymentEntity({
    required this.status,
    required this.amount,
    this.currency = 'INR',
    this.gateway = 'Razorpay (Online UPI)',
    this.method = 'UPI (Google Pay)',
    this.paymentId = '',
    this.orderId = '',
    this.receiptNo = '',
    this.paidAt = '',
    this.refundAmount,
    this.refundId,
    this.refundedAt,
    this.refundNote,
    this.refundStatus,
  });

  bool get isPaid => status == 'paid';
  bool get isRefunded => status == 'refunded';
  bool get isVoid => status == 'void';
  bool get isRefundPending => isRefunded && refundStatus == 'pending';
  bool get isPending => status == 'pending' || status == 'due';

  AppointmentPaymentEntity copyWith({
    String? status,
    double? amount,
    String? currency,
    String? gateway,
    String? method,
    String? paymentId,
    String? orderId,
    String? receiptNo,
    String? paidAt,
    double? refundAmount,
    String? refundId,
    String? refundedAt,
    String? refundNote,
    String? refundStatus,
  }) {
    return AppointmentPaymentEntity(
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      gateway: gateway ?? this.gateway,
      method: method ?? this.method,
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      receiptNo: receiptNo ?? this.receiptNo,
      paidAt: paidAt ?? this.paidAt,
      refundAmount: refundAmount ?? this.refundAmount,
      refundId: refundId ?? this.refundId,
      refundedAt: refundedAt ?? this.refundedAt,
      refundNote: refundNote ?? this.refundNote,
      refundStatus: refundStatus ?? this.refundStatus,
    );
  }

  @override
  List<Object?> get props => [
    status,
    amount,
    currency,
    gateway,
    method,
    paymentId,
    orderId,
    receiptNo,
    paidAt,
    refundAmount,
    refundId,
    refundedAt,
    refundNote,
    refundStatus,
  ];
}

/// Rich Clinic Appointment Entity matching the QueueFlow design specification.
class ClinicAppointmentEntity extends Equatable {
  final String id;
  final String bookingId;
  final String customerName;
  final String phone;
  final String email;
  final String service;
  final String serviceCategory;
  final String departmentName;
  final String serviceDuration;
  final double servicePrice;
  final String serviceDescription;
  final String doctor;
  final String doctorRole;
  final String dateTime;
  final String dateRaw;
  final String timeRaw;
  final String
  status; // 'upcoming', 'confirmed', 'checkedin', 'completed', 'cancelled'
  final String notes;
  final String type;
  final String room;
  final AppointmentPaymentEntity payment;

  const ClinicAppointmentEntity({
    required this.id,
    required this.bookingId,
    required this.customerName,
    this.phone = '+91 98765 43210',
    this.email = 'patient@email.com',
    required this.service,
    this.serviceCategory = 'General Medicine',
    this.departmentName = 'General Medicine',
    this.serviceDuration = '20 mins',
    this.servicePrice = 500.0,
    this.serviceDescription =
        'Comprehensive medical evaluation, vitals triage, physical exam, and digital prescription issuance.',
    required this.doctor,
    this.doctorRole = 'Senior Consulting Physician',
    required this.dateTime,
    this.dateRaw = '',
    this.timeRaw = '11:00 AM',
    required this.status,
    this.notes = 'Routine consultation and health checkup.',
    this.type = 'In-Person Consultation',
    this.room = 'Consultation Suite 1',
    required this.payment,
  });

  bool get isUpcoming => status.toLowerCase() == 'upcoming';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isCheckedIn =>
      status.toLowerCase() == 'checkedin' ||
      status.toLowerCase() == 'checked-in';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  String get initials {
    final parts = customerName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'PT';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  ClinicAppointmentEntity copyWith({
    String? id,
    String? bookingId,
    String? customerName,
    String? phone,
    String? email,
    String? service,
    String? serviceCategory,
    String? departmentName,
    String? serviceDuration,
    double? servicePrice,
    String? serviceDescription,
    String? doctor,
    String? doctorRole,
    String? dateTime,
    String? dateRaw,
    String? timeRaw,
    String? status,
    String? notes,
    String? type,
    String? room,
    AppointmentPaymentEntity? payment,
  }) {
    return ClinicAppointmentEntity(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      service: service ?? this.service,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      departmentName: departmentName ?? this.departmentName,
      serviceDuration: serviceDuration ?? this.serviceDuration,
      servicePrice: servicePrice ?? this.servicePrice,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      doctor: doctor ?? this.doctor,
      doctorRole: doctorRole ?? this.doctorRole,
      dateTime: dateTime ?? this.dateTime,
      dateRaw: dateRaw ?? this.dateRaw,
      timeRaw: timeRaw ?? this.timeRaw,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      room: room ?? this.room,
      payment: payment ?? this.payment,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    customerName,
    phone,
    email,
    service,
    serviceCategory,
    departmentName,
    serviceDuration,
    servicePrice,
    serviceDescription,
    doctor,
    doctorRole,
    dateTime,
    dateRaw,
    timeRaw,
    status,
    notes,
    type,
    room,
    payment,
  ];
}
