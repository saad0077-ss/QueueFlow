import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';

class CreateAppointmentUseCase {
  final BookingRepository repository;

  CreateAppointmentUseCase(this.repository);

  Future<AppointmentEntity> call(AppointmentEntity appointment) {
    return repository.createAppointment(appointment);
  }
}
