import 'package:equatable/equatable.dart';

/// Represents a patient's historical or currently active joined queue token.
class PatientQueueHistoryEntity extends Equatable {
  final String id;
  final String token;
  final String clinicId;
  final String clinicName;
  final String departmentName;
  final String serviceName;
  final String doctorName;
  final String joinedTime;
  final String date;
  final String? waitTime;
  final int position;
  final int estWaitMin;
  final String status; // 'waiting', 'called', 'completed', 'cancelled'
  final bool isActive;
  final DateTime? joinedAt;
  final String? clinicImageUrl;
  final int clinicImageVersion;
  final String doctorPhotoUrl;

  const PatientQueueHistoryEntity({
    required this.id,
    required this.token,
    required this.clinicId,
    required this.clinicName,
    this.departmentName = 'General Medicine',
    required this.serviceName,
    this.doctorName = '',
    required this.joinedTime,
    required this.date,
    this.waitTime,
    this.position = 0,
    this.estWaitMin = 0,
    this.status = 'waiting',
    this.isActive = false,
    this.joinedAt,
    this.clinicImageUrl,
    this.clinicImageVersion = 0,
    this.doctorPhotoUrl = '',
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isCalled => status.toLowerCase() == 'called';

  PatientQueueHistoryEntity copyWith({
    String? id,
    String? token,
    String? clinicId,
    String? clinicName,
    String? departmentName,
    String? serviceName,
    String? doctorName,
    String? joinedTime,
    String? date,
    String? waitTime,
    int? position,
    int? estWaitMin,
    String? status,
    bool? isActive,
    DateTime? joinedAt,
    String? clinicImageUrl,
    int? clinicImageVersion,
    String? doctorPhotoUrl,
  }) {
    return PatientQueueHistoryEntity(
      id: id ?? this.id,
      token: token ?? this.token,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      departmentName: departmentName ?? this.departmentName,
      serviceName: serviceName ?? this.serviceName,
      doctorName: doctorName ?? this.doctorName,
      joinedTime: joinedTime ?? this.joinedTime,
      date: date ?? this.date,
      waitTime: waitTime ?? this.waitTime,
      position: position ?? this.position,
      estWaitMin: estWaitMin ?? this.estWaitMin,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt ?? this.joinedAt,
      clinicImageUrl: clinicImageUrl ?? this.clinicImageUrl,
      clinicImageVersion: clinicImageVersion ?? this.clinicImageVersion,
      doctorPhotoUrl: doctorPhotoUrl ?? this.doctorPhotoUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    token,
    clinicId,
    clinicName,
    departmentName,
    serviceName,
    doctorName,
    joinedTime,
    date,
    waitTime,
    position,
    estWaitMin,
    status,
    isActive,
    joinedAt,
    clinicImageUrl,
    clinicImageVersion,
    doctorPhotoUrl,
  ];
}
