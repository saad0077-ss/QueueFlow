import 'package:equatable/equatable.dart';

/// Single completed or confirmed consultation audit entry for the register.
class ConsultationAuditItem extends Equatable {
  final String id;
  final String patientName;
  final String tokenNumber;
  final String doctorName;
  final String serviceName;
  final String status;
  final double consultationFee;
  final String dateTime;

  const ConsultationAuditItem({
    required this.id,
    required this.patientName,
    required this.tokenNumber,
    required this.doctorName,
    required this.serviceName,
    required this.status,
    required this.consultationFee,
    this.dateTime = '',
  });

  @override
  List<Object?> get props => [
    id,
    patientName,
    tokenNumber,
    doctorName,
    serviceName,
    status,
    consultationFee,
    dateTime,
  ];
}
