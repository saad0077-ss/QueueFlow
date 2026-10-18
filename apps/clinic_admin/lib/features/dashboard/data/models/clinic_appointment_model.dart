import '../../domain/entities/clinic_appointment_entity.dart';

/// Data model representing an appointment with mapping utilities.
class ClinicAppointmentModel extends ClinicAppointmentEntity {
  const ClinicAppointmentModel({
    required super.time,
    required super.customer,
    required super.service,
    required super.doctor,
    required super.status,
    super.isCompleted,
  });

  factory ClinicAppointmentModel.fromMap(Map<String, dynamic> map) {
    return ClinicAppointmentModel(
      time: map['time'] as String? ?? '',
      customer: map['customer'] as String? ?? '',
      service: map['service'] as String? ?? '',
      doctor: map['doctor'] as String? ?? '',
      status: map['status'] as String? ?? 'SCHEDULED',
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'customer': customer,
      'service': service,
      'doctor': doctor,
      'status': status,
      'isCompleted': isCompleted,
    };
  }

  /// Official mock appointments list matching the dashboard UI.
  static const List<ClinicAppointmentModel> sampleList = [
    ClinicAppointmentModel(
      time: '2:00PM',
      customer: 'Aisha Rahman',
      service: 'Root Canal Treatment',
      doctor: 'Dr.Meera Iyer',
      status: 'RESCHEDULED',
      isCompleted: false,
    ),
    ClinicAppointmentModel(
      time: '2:15 PM',
      customer: 'Aisha Rahman',
      service: 'Root Canal Treatment',
      doctor: 'Dr.Rahul Menon',
      status: 'COMPLETED',
      isCompleted: true,
    ),
    ClinicAppointmentModel(
      time: '2:00PM',
      customer: 'Vivek Nair',
      service: 'Root Canal Treatment',
      doctor: 'Dr.Fatima Noor',
      status: 'RESCHEDULED',
      isCompleted: false,
    ),
    ClinicAppointmentModel(
      time: '3:00PM',
      customer: 'Aisha Rahman',
      service: 'Root Canal Treatment',
      doctor: 'Dr.Rahul Menon',
      status: 'CHECKEDIN',
      isCompleted: false,
    ),
    ClinicAppointmentModel(
      time: '3:00PM',
      customer: 'Aisha Rahman',
      service: 'Root Canal Treatment',
      doctor: 'Dr.Fatima Noor',
      status: 'COMPLETED',
      isCompleted: true,
    ),
  ];
}
