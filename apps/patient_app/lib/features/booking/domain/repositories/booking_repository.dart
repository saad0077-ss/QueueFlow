import 'package:patient_app/features/clinic_details/domain/entities/clinic_doctor_item.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_service_item.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';

abstract class BookingRepository {
  Future<List<ClinicServiceItem>> getClinicServices(String clinicId, String category);

  Future<List<ClinicDoctorItem>> getClinicDoctors(String clinicId, String category);

  Future<List<String>> getAvailableTimeSlots({
    required String clinicId,
    required String doctorId,
    required DateTime date,
  });

  Future<AppointmentEntity> createAppointment(AppointmentEntity appointment);

  Future<List<AppointmentEntity>> getUserAppointments({
    String? customerId,
    String? customerEmail,
  });

  Stream<List<AppointmentEntity>> watchUserAppointments({
    String? customerId,
    String? customerEmail,
  });

  Future<void> cancelAppointment(String appointmentId);
}
