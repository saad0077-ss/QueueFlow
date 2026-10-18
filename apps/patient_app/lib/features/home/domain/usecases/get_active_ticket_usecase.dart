import '../entities/active_ticket_entity.dart';
import '../repositories/home_repository.dart';

class GetActiveTicketUseCase {
  final HomeRepository repository;

  GetActiveTicketUseCase(this.repository);

  Future<ActiveTicketEntity?> call() => repository.getActiveTicket();
}
