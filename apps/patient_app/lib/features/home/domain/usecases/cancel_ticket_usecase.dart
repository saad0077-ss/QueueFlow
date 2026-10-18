import '../repositories/home_repository.dart';

class CancelTicketUseCase {
  final HomeRepository repository;

  CancelTicketUseCase(this.repository);

  Future<void> call(String ticketId) => repository.cancelTicket(ticketId);
}
