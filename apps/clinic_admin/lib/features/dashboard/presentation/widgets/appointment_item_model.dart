import '../../domain/entities/clinic_appointment_entity.dart';

/// Presentation-layer model representing an upcoming appointment item,
/// extending the domain [ClinicAppointmentEntity].
class AppointmentItem extends ClinicAppointmentEntity {
  const AppointmentItem({
    required super.time,
    required super.customer,
    required super.service,
    required super.doctor,
    required super.status,
    super.isCompleted,
  });

  /// Sample mock appointments matching the official design.
  static const List<AppointmentItem> defaultList = [
    AppointmentItem(
      time: '2:00PM',
      customer: 'Aisha Rahman',
      service: 'Root Canal Treatment',
      doctor: 'Dr.Meera Iyer',
      status: 'RESCHEDULED',
      isCompleted: false,
    ),
    AppointmentItem(
      time: '2:15 PM',
      customer: 'Aisha Rahman',
      service: 'Root Canal Treatment',
      doctor: 'Dr.Rahul Menon',
      status: 'COMPLETED',
      isCompleted: true,
    ),
    AppointmentItem(
      time: '2:00PM',
      customer: 'Vivek Nair',
      service: 'Root Canal Treatment',
      doctor: 'Dr.Fatima Noor',
      status: 'RESCHEDULED',
      isCompleted: false,
    ),
    AppointmentItem(
      time: '3:00PM',
      customer: 'Aisha Rahman',
      service: 'Root Canal Treatment',
      doctor: 'Dr.Rahul Menon',
      status: 'CHECKEDIN',
      isCompleted: false,
    ),
    AppointmentItem(
      time: '3:00PM',
      customer: 'Aisha Rahman',
      service: 'Root Canal Treatment',
      doctor: 'Dr.Fatima Noor',
      status: 'COMPLETED',
      isCompleted: true,
    ),
  ];
}
