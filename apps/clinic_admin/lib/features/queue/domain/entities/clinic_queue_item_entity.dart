import 'package:equatable/equatable.dart';

/// Domain entity representing a patient in the live queue.
class ClinicQueueItemEntity extends Equatable {
  final String id;
  final String token;
  final String clinicId;
  final String patientName;
  final String serviceName;
  final String doctorName;
  final String phone;
  final String email;
  final String joinedTime;
  final DateTime joinedAt;
  final String estDuration;
  final String
  status; // 'waiting', 'called', 'completed', 'skipped', 'cancelled'
  final String note;
  final String paymentStatus; // 'paid', 'pending', 'unpaid'

  const ClinicQueueItemEntity({
    required this.id,
    required this.token,
    required this.clinicId,
    required this.patientName,
    this.serviceName = 'General Consultation',
    this.doctorName = '',
    this.phone = '',
    this.email = '',
    this.joinedTime = '',
    required this.joinedAt,
    this.estDuration = '20 min',
    this.status = 'waiting',
    this.note = '',
    this.paymentStatus = 'paid',
  });

  bool get isWaiting => status == 'waiting';
  bool get isCalled => status == 'called';
  bool get isCompleted => status == 'completed';
  bool get isSkipped => status == 'skipped';
  bool get isCancelled => status == 'cancelled';

  ClinicQueueItemEntity copyWith({
    String? id,
    String? token,
    String? clinicId,
    String? patientName,
    String? serviceName,
    String? doctorName,
    String? phone,
    String? email,
    String? joinedTime,
    DateTime? joinedAt,
    String? estDuration,
    String? status,
    String? note,
    String? paymentStatus,
  }) {
    return ClinicQueueItemEntity(
      id: id ?? this.id,
      token: token ?? this.token,
      clinicId: clinicId ?? this.clinicId,
      patientName: patientName ?? this.patientName,
      serviceName: serviceName ?? this.serviceName,
      doctorName: doctorName ?? this.doctorName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      joinedTime: joinedTime ?? this.joinedTime,
      joinedAt: joinedAt ?? this.joinedAt,
      estDuration: estDuration ?? this.estDuration,
      status: status ?? this.status,
      note: note ?? this.note,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    token,
    clinicId,
    patientName,
    serviceName,
    doctorName,
    phone,
    email,
    joinedTime,
    joinedAt,
    estDuration,
    status,
    note,
    paymentStatus,
  ];
}
