import '../repositories/platform_support_repository.dart';

class UpdatePlatformTicketPriorityUseCase {
  final PlatformSupportRepository repository;
  const UpdatePlatformTicketPriorityUseCase(this.repository);

  Future<void> call({required String ticketId, required String priority}) {
    return repository.updatePriority(ticketId: ticketId, priority: priority);
  }
}
