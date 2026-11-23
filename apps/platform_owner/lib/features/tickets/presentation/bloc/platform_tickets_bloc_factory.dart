import '../../data/repositories/platform_support_repository_impl.dart';
import '../../domain/repositories/platform_support_repository.dart';
import '../../domain/usecases/platform_tickets_usecases.dart';
import 'platform_tickets_bloc.dart';

class PlatformTicketsBlocFactory {
  static PlatformTicketsBloc create({PlatformSupportRepository? repository}) {
    final repo = repository ?? PlatformSupportRepositoryImpl();
    return PlatformTicketsBloc(
      watchTickets: WatchPlatformTicketsUseCase(repo),
      sendReply: SendPlatformTicketReplyUseCase(repo),
      updateStatus: UpdatePlatformTicketStatusUseCase(repo),
      updatePriority: UpdatePlatformTicketPriorityUseCase(repo),
      deleteTicket: DeletePlatformTicketUseCase(repo),
    );
  }
}
