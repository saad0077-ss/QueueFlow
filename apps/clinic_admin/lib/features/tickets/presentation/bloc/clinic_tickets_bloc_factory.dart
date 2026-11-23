import '../../data/repositories/clinic_support_repository_impl.dart';
import '../../domain/repositories/clinic_support_repository.dart';
import '../../domain/usecases/clinic_tickets_usecases.dart';
import 'clinic_tickets_bloc.dart';

class ClinicTicketsBlocFactory {
  static ClinicTicketsBloc create({ClinicSupportRepository? repository}) {
    final repo = repository ?? ClinicSupportRepositoryImpl();
    return ClinicTicketsBloc(
      watchTickets: WatchClinicTicketsUseCase(repo),
      sendReply: SendTicketReplyUseCase(repo),
      updateStatus: UpdateTicketStatusUseCase(repo),
      updatePriority: UpdateTicketPriorityUseCase(repo),
      escalateTicket: EscalateTicketUseCase(repo),
    );
  }
}
