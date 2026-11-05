import '../entities/clinic_appointment_entity.dart';

abstract class ClinicAppointmentsRepository {
  Stream<List<ClinicAppointmentEntity>> watchAppointments();
  Future<void> addAppointment(ClinicAppointmentEntity appointment);
  Future<void> checkInAppointment(String id);
  Future<void> completeAppointment(String id);
  Future<void> rescheduleAppointment(String id, String newDate, String newTime);
  Future<void> cancelAppointment(
    String id, {
    String? reason,
    double? refundAmount,
  });
  Future<String> exportAppointmentsCsv();
}
