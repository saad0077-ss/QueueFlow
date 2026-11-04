import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';

class GetUserAppointmentsUseCase {
  final BookingRepository repository;

  GetUserAppointmentsUseCase(this.repository);

  Future<List<AppointmentEntity>> call({String? customerId, String? customerEmail}) {
    return repository.getUserAppointments(
      customerId: customerId,
      customerEmail: customerEmail,
    );
  }

  Stream<List<AppointmentEntity>> watch({String? customerId, String? customerEmail}) {
    return repository.watchUserAppointments(
      customerId: customerId,
      customerEmail: customerEmail,
    );
  }
}
