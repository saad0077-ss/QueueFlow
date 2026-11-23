import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/platform_tickets_usecases.dart';
import 'platform_tickets_event.dart';
import 'platform_tickets_state.dart';

class PlatformTicketsBloc
    extends Bloc<PlatformTicketsEvent, PlatformTicketsState> {
  final WatchPlatformTicketsUseCase watchTickets;
  final SendPlatformTicketReplyUseCase sendReply;
  final UpdatePlatformTicketStatusUseCase updateStatus;
  final UpdatePlatformTicketPriorityUseCase updatePriority;
  final DeletePlatformTicketUseCase deleteTicket;

  StreamSubscription? _subscription;

  PlatformTicketsBloc({
    required this.watchTickets,
    required this.sendReply,
    required this.updateStatus,
    required this.updatePriority,
    required this.deleteTicket,
  }) : super(const PlatformTicketsState()) {
    on<WatchPlatformTicketsStarted>(_onWatchTickets);
    on<PlatformTicketsUpdated>(_onTicketsUpdated);
    on<PlatformTicketsStatusFilterChanged>(_onStatusFilterChanged);
    on<PlatformTicketsModalFiltersApplied>(_onModalFiltersApplied);
    on<PlatformTicketsSearchChanged>(_onSearchChanged);
    on<PlatformTicketSelected>(_onTicketSelected);
    on<PlatformTicketViewChatToggled>(_onViewChatToggled);
    on<PlatformTicketViewModeToggled>(_onViewModeToggled);
    on<PlatformTicketReplySubmitted>(_onReplySubmitted);
    on<PlatformTicketStatusSubmitted>(_onStatusSubmitted);
    on<PlatformTicketPrioritySubmitted>(_onPrioritySubmitted);
    on<PlatformTicketDeleteSubmitted>(_onDeleteSubmitted);
  }

  Future<void> _onWatchTickets(
    WatchPlatformTicketsStarted event,
    Emitter<PlatformTicketsState> emit,
  ) async {
    emit(state.copyWith(status: PlatformTicketsStatus.loading));
    await _subscription?.cancel();
    _subscription = watchTickets().listen(
      (tickets) => add(PlatformTicketsUpdated(tickets)),
    );
  }

  void _onTicketsUpdated(
    PlatformTicketsUpdated event,
    Emitter<PlatformTicketsState> emit,
  ) {
    emit(
      state.copyWith(
        status: PlatformTicketsStatus.loaded,
        allTickets: event.tickets,
      ),
    );
  }

  void _onStatusFilterChanged(
    PlatformTicketsStatusFilterChanged event,
    Emitter<PlatformTicketsState> emit,
  ) {
    emit(state.copyWith(statusFilter: event.status));
  }

  void _onModalFiltersApplied(
    PlatformTicketsModalFiltersApplied event,
    Emitter<PlatformTicketsState> emit,
  ) {
    emit(
      state.copyWith(
        clinicFilter: event.clinic,
        categoryFilter: event.category,
        urgencyFilter: event.urgency,
      ),
    );
  }

  void _onSearchChanged(
    PlatformTicketsSearchChanged event,
    Emitter<PlatformTicketsState> emit,
  ) => emit(state.copyWith(searchQuery: event.query.trim()));

  void _onTicketSelected(
    PlatformTicketSelected event,
    Emitter<PlatformTicketsState> emit,
  ) => emit(state.copyWith(selectedTicketId: event.ticketId));

  void _onViewChatToggled(
    PlatformTicketViewChatToggled event,
    Emitter<PlatformTicketsState> emit,
  ) => emit(state.copyWith(isViewingChat: event.isViewing));

  void _onViewModeToggled(
    PlatformTicketViewModeToggled event,
    Emitter<PlatformTicketsState> emit,
  ) => emit(state.copyWith(isMatrixView: event.isMatrixView));

  Future<void> _onReplySubmitted(
    PlatformTicketReplySubmitted event,
    Emitter<PlatformTicketsState> emit,
  ) async {
    await sendReply(
      ticketId: event.ticketId,
      text: event.text,
      senderName: event.senderName,
      isInternalNote: event.isInternalNote,
    );
  }

  Future<void> _onStatusSubmitted(
    PlatformTicketStatusSubmitted event,
    Emitter<PlatformTicketsState> emit,
  ) async {
    await updateStatus(
      ticketId: event.ticketId,
      status: event.status,
      staffName: event.staffName,
    );
  }

  Future<void> _onPrioritySubmitted(
    PlatformTicketPrioritySubmitted event,
    Emitter<PlatformTicketsState> emit,
  ) async {
    await updatePriority(ticketId: event.ticketId, priority: event.priority);
  }

  Future<void> _onDeleteSubmitted(
    PlatformTicketDeleteSubmitted event,
    Emitter<PlatformTicketsState> emit,
  ) async {
    await deleteTicket(ticketId: event.ticketId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
