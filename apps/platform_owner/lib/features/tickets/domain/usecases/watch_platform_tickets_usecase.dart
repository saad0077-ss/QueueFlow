import '../entities/platform_support_ticket_entity.dart';
import '../repositories/platform_support_repository.dart';

class WatchPlatformTicketsUseCase {
  final PlatformSupportRepository repository;
  const WatchPlatformTicketsUseCase(this.repository);

  Stream<List<PlatformSupportTicketEntity>> call() =>
      repository.watchAllTickets();
}
