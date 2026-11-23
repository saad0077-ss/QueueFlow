import '../entities/clinic_support_ticket_entity.dart';
import '../repositories/clinic_support_repository.dart';

class WatchClinicTicketsUseCase {
  final ClinicSupportRepository repository;

  const WatchClinicTicketsUseCase(this.repository);

  Stream<List<ClinicSupportTicketEntity>> call({
    required String clinicId,
    String? clinicName,
  }) {
    return repository.watchClinicTickets(
      clinicId: clinicId,
      clinicName: clinicName,
    );
  }
}
