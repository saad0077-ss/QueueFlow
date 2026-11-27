import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';

class ClinicQueueItemModel extends ClinicQueueItemEntity {
  const ClinicQueueItemModel({
    required super.id,
    required super.token,
    required super.clinicId,
    required super.patientName,
    super.serviceName,
    super.doctorName,
    super.phone,
    super.email,
    super.joinedTime,
    required super.joinedAt,
    super.estDuration,
    super.status,
    super.note,
    super.paymentStatus,
    super.fee,
  });

  factory ClinicQueueItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ClinicQueueItemModel.fromMap(data, id: doc.id);
  }

  factory ClinicQueueItemModel.fromMap(
    Map<String, dynamic> data, {
    required String id,
  }) {
    DateTime joinedDate = DateTime.now();
    final rawJoined = data['joinedAt'] ?? data['createdAt'];
    if (rawJoined is Timestamp) {
      joinedDate = rawJoined.toDate();
    } else if (rawJoined is String) {
      joinedDate = DateTime.tryParse(rawJoined) ?? DateTime.now();
    }

    final hour = joinedDate.hour;
    final minute = joinedDate.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final defaultJoinedTime = '$h12:$minute $ampm';

    return ClinicQueueItemModel(
      id: id,
      token: (data['token'] ?? data['queueToken'] ?? 'A-000').toString(),
      clinicId: (data['clinicId'] ?? '').toString(),
      patientName:
          (data['patientName'] ?? data['customerName'] ?? 'Walk-In Patient')
              .toString(),
      serviceName:
          (data['serviceName'] ?? data['service'] ?? 'General Consultation')
              .toString(),
      doctorName: (data['doctorName'] ?? data['doctor'] ?? '').toString(),
      phone: (data['phone'] ?? data['patientPhone'] ?? '').toString(),
      email: (data['email'] ?? data['patientEmail'] ?? '').toString(),
      joinedTime: (data['joinedTime'] ?? defaultJoinedTime).toString(),
      joinedAt: joinedDate,
      estDuration: (data['estDuration'] ?? '20 min').toString(),
      status: (data['status'] ?? 'waiting').toString().toLowerCase(),
      note: (data['note'] ?? data['notes'] ?? '').toString(),
      paymentStatus: (data['paymentStatus'] ?? data['payment'] ?? 'paid')
          .toString()
          .toLowerCase(),
      fee:
          ((data['servicePrice'] ??
                      data['fee'] ??
                      data['price'] ??
                      data['amount'])
                  as num?)
              ?.toDouble() ??
          0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'clinicId': clinicId,
      'patientName': patientName,
      'serviceName': serviceName,
      'doctorName': doctorName,
      'phone': phone,
      'email': email,
      'joinedTime': joinedTime,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'estDuration': estDuration,
      'status': status,
      'note': note,
      'paymentStatus': paymentStatus,
    };
  }
}
