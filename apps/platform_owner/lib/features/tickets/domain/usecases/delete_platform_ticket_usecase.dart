import '../repositories/platform_support_repository.dart';

class DeletePlatformTicketUseCase {
  final PlatformSupportRepository repository;
  const DeletePlatformTicketUseCase(this.repository);

  Future<void> call({required String ticketId}) {
    return repository.deleteTicket(ticketId: ticketId);
  }
}
