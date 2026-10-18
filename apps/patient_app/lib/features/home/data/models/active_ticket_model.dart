import '../../domain/entities/active_ticket_entity.dart';

/// Active digital queue ticket model extending the domain ActiveTicketEntity.
class ActiveTicketModel extends ActiveTicketEntity {
  const ActiveTicketModel({
    required super.id,
    required super.token,
    required super.clinicId,
    required super.clinicName,
    super.serviceName = 'General Consultation',
    super.doctorName = 'Dr. Priya',
    super.position = 3,
    super.estWaitMin = 15,
    super.nowServing = 'A-021',
    super.status = 'waiting',
    super.joinedAt,
  });

  factory ActiveTicketModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ActiveTicketModel(
      id: id ?? map['id'] ?? '',
      token: map['token'] ?? '',
      clinicId: map['clinicId'] ?? '',
      clinicName: map['clinicName'] ?? '',
      serviceName: map['serviceName'] ?? 'General Consultation',
      doctorName: map['doctorName'] ?? 'Attending Doctor',
      position: (map['position'] as num?)?.toInt() ?? 1,
      estWaitMin: (map['estWaitMin'] as num?)?.toInt() ?? 10,
      nowServing: map['nowServing'] ?? '---',
      status: map['status'] ?? 'waiting',
      joinedAt: map['joinedAt'] != null
          ? DateTime.tryParse(map['joinedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'serviceName': serviceName,
      'doctorName': doctorName,
      'position': position,
      'estWaitMin': estWaitMin,
      'nowServing': nowServing,
      'status': status,
      'joinedAt': joinedAt?.toIso8601String(),
    };
  }
}
