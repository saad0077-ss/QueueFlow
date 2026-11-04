import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/entities/payment_info_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.bookingRef,
    required super.clinicId,
    required super.clinicName,
    super.clinicAddress,
    required super.customerId,
    required super.customerName,
    super.customerPhone,
    super.customerEmail,
    required super.doctorId,
    required super.doctorName,
    super.doctorSpecialty,
    required super.serviceId,
    required super.serviceName,
    super.serviceDuration,
    super.servicePrice,
    required super.dateRaw,
    required super.timeRaw,
    required super.dateTime,
    super.status,
    super.payment,
    super.notes,
    required super.createdAt,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final map = (doc.data() as Map<String, dynamic>?) ?? {};
    return AppointmentModel.fromMap(map, id: doc.id);
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedCreatedAt;
    final rawCreated = map['createdAt'];
    if (rawCreated is Timestamp) {
      parsedCreatedAt = rawCreated.toDate();
    } else if (rawCreated is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    PaymentInfoEntity? paymentInfo;
    if (map['payment'] is Map<String, dynamic>) {
      paymentInfo = PaymentInfoEntity.fromMap(map['payment'] as Map<String, dynamic>);
    } else if (map['paymentId'] != null) {
      paymentInfo = PaymentInfoEntity(
        paymentId: map['paymentId'].toString(),
        amount: (map['servicePrice'] as num?)?.toDouble() ?? 500.0,
        method: (map['paymentMethod'] ?? 'Razorpay (Test Mode)').toString(),
        paidAt: (map['paidAt'] ?? '').toString(),
      );
    }

    return AppointmentModel(
      id: id ?? (map['id'] ?? '').toString(),
      bookingRef: (map['bookingRef'] ?? map['bookingId'] ?? 'QF-00000').toString(),
      clinicId: (map['clinicId'] ?? '').toString(),
      clinicName: (map['clinicName'] ?? 'Clinic').toString(),
      clinicAddress: (map['clinicAddress'] ?? map['address'] ?? '').toString(),
      customerId: (map['customerId'] ?? map['patientId'] ?? map['userId'] ?? '').toString(),
      customerName: (map['customerName'] ?? map['patientName'] ?? map['customer'] ?? 'Patient').toString(),
      customerPhone: (map['customerPhone'] ?? map['phone'] ?? '').toString(),
      customerEmail: (map['customerEmail'] ?? map['email'] ?? '').toString(),
      doctorId: (map['doctorId'] ?? '').toString(),
      doctorName: (map['doctorName'] ?? map['doctor'] ?? 'Doctor').toString(),
      doctorSpecialty: (map['doctorSpecialty'] ?? map['specialty'] ?? '').toString(),
      serviceId: (map['serviceId'] ?? '').toString(),
      serviceName: (map['serviceName'] ?? map['service'] ?? 'General Consultation').toString(),
      serviceDuration: (map['serviceDuration'] as num?)?.toInt() ?? (map['duration'] as num?)?.toInt() ?? 20,
      servicePrice: (map['servicePrice'] as num?)?.toDouble() ?? (map['price'] as num?)?.toDouble() ?? 500.0,
      dateRaw: (map['dateRaw'] ?? map['date'] ?? '').toString(),
      timeRaw: (map['timeRaw'] ?? map['time'] ?? map['timeSlot'] ?? '').toString(),
      dateTime: (map['dateTime'] ?? '').toString(),
      status: (map['status'] ?? 'confirmed').toString(),
      payment: paymentInfo,
      notes: (map['notes'] ?? '').toString(),
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingRef': bookingRef,
      'bookingId': bookingRef,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'customerId': customerId,
      'customerName': customerName,
      'customer': customerName,
      'patientName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctor': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'service': serviceName,
      'serviceDuration': serviceDuration,
      'servicePrice': servicePrice,
      'price': servicePrice,
      'dateRaw': dateRaw,
      'date': dateRaw,
      'timeRaw': timeRaw,
      'time': timeRaw,
      'timeSlot': timeRaw,
      'dateTime': dateTime,
      'status': status,
      'isCompleted': isCompleted,
      'payment': payment?.toMap(),
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
