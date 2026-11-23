import '../repositories/clinic_support_repository.dart';

class EscalateTicketUseCase {
  final ClinicSupportRepository repository;

  const EscalateTicketUseCase(this.repository);

  Future<void> call({required String ticketId, required String staffName}) {
    return repository.escalateTicket(ticketId: ticketId, staffName: staffName);
  }
}
