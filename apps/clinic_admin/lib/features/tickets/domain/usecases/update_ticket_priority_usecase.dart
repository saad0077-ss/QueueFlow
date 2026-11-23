import '../repositories/clinic_support_repository.dart';

class UpdateTicketPriorityUseCase {
  final ClinicSupportRepository repository;

  const UpdateTicketPriorityUseCase(this.repository);

  Future<void> call({required String ticketId, required String priority}) {
    return repository.updatePriority(ticketId: ticketId, priority: priority);
  }
}
