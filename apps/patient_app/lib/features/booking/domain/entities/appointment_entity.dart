import 'package:equatable/equatable.dart';
import 'payment_info_entity.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String bookingRef;
  final String clinicId;
  final String clinicName;
  final String clinicAddress;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String serviceId;
  final String serviceName;
  final int serviceDuration;
  final double servicePrice;
  final String dateRaw;
  final String timeRaw;
  final String dateTime;
  final String status;
  final PaymentInfoEntity? payment;
  final String notes;
  final DateTime createdAt;

  const AppointmentEntity({
    required this.id,
    required this.bookingRef,
    required this.clinicId,
    required this.clinicName,
    this.clinicAddress = '',
    required this.customerId,
    required this.customerName,
    this.customerPhone = '',
    this.customerEmail = '',
    required this.doctorId,
    required this.doctorName,
    this.doctorSpecialty = '',
    required this.serviceId,
    required this.serviceName,
    this.serviceDuration = 20,
    this.servicePrice = 500,
    required this.dateRaw,
    required this.timeRaw,
    required this.dateTime,
    this.status = 'confirmed',
    this.payment,
    this.notes = '',
    required this.createdAt,
  });

  bool get isUpcoming =>
      status.toLowerCase() == 'confirmed' ||
      status.toLowerCase() == 'upcoming' ||
      status.toLowerCase() == 'scheduled' ||
      isCheckedIn ||
      status.toLowerCase() == 'rescheduled' ||
      status.toLowerCase() == 'pending';

  /// The clinic has checked the patient in at the front desk.
  bool get isCheckedIn =>
      status.toLowerCase() == 'checkedin' ||
      status.toLowerCase() == 'checked-in';

  /// Money was collected (a refunded booking was paid before the refund).
  bool get isPaid =>
      payment != null &&
      (payment!.status.toLowerCase() == 'paid' ||
          payment!.status.toLowerCase() == 'refunded');

  /// Upcoming booking that is unpaid or explicitly pending.
  bool get isPending =>
      isUpcoming && (status.toLowerCase() == 'pending' || !isPaid);

  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isCancelled =>
      status.toLowerCase() == 'cancelled' ||
      status.toLowerCase() == 'noshow' ||
      status.toLowerCase() == 'skipped';

  AppointmentEntity copyWith({
    String? id,
    String? bookingRef,
    String? clinicId,
    String? clinicName,
    String? clinicAddress,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    String? serviceId,
    String? serviceName,
    int? serviceDuration,
    double? servicePrice,
    String? dateRaw,
    String? timeRaw,
    String? dateTime,
    String? status,
    PaymentInfoEntity? payment,
    String? notes,
    DateTime? createdAt,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      bookingRef: bookingRef ?? this.bookingRef,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceDuration: serviceDuration ?? this.serviceDuration,
      servicePrice: servicePrice ?? this.servicePrice,
      dateRaw: dateRaw ?? this.dateRaw,
      timeRaw: timeRaw ?? this.timeRaw,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      payment: payment ?? this.payment,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingRef,
        clinicId,
        clinicName,
        clinicAddress,
        customerId,
        customerName,
        customerPhone,
        customerEmail,
        doctorId,
        doctorName,
        doctorSpecialty,
        serviceId,
        serviceName,
        serviceDuration,
        servicePrice,
        dateRaw,
        timeRaw,
        dateTime,
        status,
        payment,
        notes,
        createdAt,
      ];
}
