import 'package:equatable/equatable.dart';

class ActiveTicketEntity extends Equatable {
  final String id;
  final String token;
  final String clinicId;
  final String clinicName;
  final String serviceName;
  final String doctorName;
  final int position;
  final int estWaitMin;
  final String nowServing;
  final String status;
  final DateTime? joinedAt;

  const ActiveTicketEntity({
    required this.id,
    required this.token,
    required this.clinicId,
    required this.clinicName,
    this.serviceName = 'General Consultation',
    this.doctorName = 'Dr. Priya',
    this.position = 3,
    this.estWaitMin = 15,
    this.nowServing = 'A-021',
    this.status = 'waiting',
    this.joinedAt,
  });

  bool get isActive => status != 'completed' && status != 'cancelled';

  double get progressFraction {
    if (status == 'called') return 0.90;
    if (position <= 1) return 0.75;
    if (position <= 2) return 0.60;
    return 0.40;
  }

  @override
  List<Object?> get props => [
        id,
        token,
        clinicId,
        clinicName,
        serviceName,
        doctorName,
        position,
        estWaitMin,
        nowServing,
        status,
        joinedAt,
      ];
}
