import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';

class CancelAppointmentUseCase {
  final BookingRepository repository;

  CancelAppointmentUseCase(this.repository);

  Future<void> call(String appointmentId) {
    return repository.cancelAppointment(appointmentId);
  }
}
