import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/clinic_tickets_usecases.dart';
import 'clinic_tickets_event.dart';
import 'clinic_tickets_state.dart';

class ClinicTicketsBloc extends Bloc<ClinicTicketsEvent, ClinicTicketsState> {
  final WatchClinicTicketsUseCase _watchTickets;
  final SendTicketReplyUseCase _sendReply;
  final UpdateTicketStatusUseCase _updateStatus;
  final UpdateTicketPriorityUseCase _updatePriority;
  final EscalateTicketUseCase _escalateTicket;

  StreamSubscription? _subscription;

  ClinicTicketsBloc({
    required WatchClinicTicketsUseCase watchTickets,
    required SendTicketReplyUseCase sendReply,
    required UpdateTicketStatusUseCase updateStatus,
    required UpdateTicketPriorityUseCase updatePriority,
    required EscalateTicketUseCase escalateTicket,
  }) : _watchTickets = watchTickets,
       _sendReply = sendReply,
       _updateStatus = updateStatus,
       _updatePriority = updatePriority,
       _escalateTicket = escalateTicket,
       super(const ClinicTicketsState()) {
    on<WatchClinicTicketsStarted>(_onWatchTickets);
    on<ClinicTicketsUpdated>(_onTicketsUpdated);
    on<ClinicTicketsStatusFilterChanged>(_onStatusFilterChanged);
    on<ClinicTicketsModalFiltersApplied>(_onModalFiltersApplied);
    on<ClinicTicketsSearchChanged>(_onSearchChanged);
    on<ClinicTicketSelected>(_onTicketSelected);
    on<ClinicTicketViewChatToggled>(_onViewChatToggled);
    on<ClinicTicketReplySubmitted>(_onReplySubmitted);
    on<ClinicTicketStatusSubmitted>(_onStatusSubmitted);
    on<ClinicTicketPrioritySubmitted>(_onPrioritySubmitted);
    on<ClinicTicketEscalateSubmitted>(_onEscalateSubmitted);
  }

  Future<void> _onWatchTickets(
    WatchClinicTicketsStarted event,
    Emitter<ClinicTicketsState> emit,
  ) async {
    emit(state.copyWith(status: ClinicTicketsStatus.loading));
    await _subscription?.cancel();
    _subscription = _watchTickets(
      clinicId: event.clinicId,
      clinicName: event.clinicName,
    ).listen((tickets) => add(ClinicTicketsUpdated(tickets)));
  }

  void _onTicketsUpdated(
    ClinicTicketsUpdated event,
    Emitter<ClinicTicketsState> emit,
  ) {
    emit(
      state.copyWith(
        status: ClinicTicketsStatus.loaded,
        allTickets: event.tickets,
      ),
    );
  }

  void _onStatusFilterChanged(
    ClinicTicketsStatusFilterChanged event,
    Emitter<ClinicTicketsState> emit,
  ) {
    emit(state.copyWith(statusFilter: event.status));
  }

  void _onModalFiltersApplied(
    ClinicTicketsModalFiltersApplied event,
    Emitter<ClinicTicketsState> emit,
  ) {
    emit(
      state.copyWith(
        categoryFilter: event.category,
        urgencyFilter: event.urgency,
        serviceFilter: event.service,
      ),
    );
  }

  void _onSearchChanged(
    ClinicTicketsSearchChanged event,
    Emitter<ClinicTicketsState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query.trim()));
  }

  void _onTicketSelected(
    ClinicTicketSelected event,
    Emitter<ClinicTicketsState> emit,
  ) {
    emit(state.copyWith(selectedTicketId: event.ticketId));
  }

  void _onViewChatToggled(
    ClinicTicketViewChatToggled event,
    Emitter<ClinicTicketsState> emit,
  ) {
    emit(state.copyWith(isViewingChat: event.isViewing));
  }

  Future<void> _onReplySubmitted(
    ClinicTicketReplySubmitted event,
    Emitter<ClinicTicketsState> emit,
  ) async {
    await _sendReply(
      ticketId: event.ticketId,
      text: event.text,
      staffName: event.staffName,
      isInternalNote: event.isInternalNote,
    );
  }

  Future<void> _onStatusSubmitted(
    ClinicTicketStatusSubmitted event,
    Emitter<ClinicTicketsState> emit,
  ) async {
    await _updateStatus(
      ticketId: event.ticketId,
      status: event.status,
      staffName: event.staffName,
    );
  }

  Future<void> _onPrioritySubmitted(
    ClinicTicketPrioritySubmitted event,
    Emitter<ClinicTicketsState> emit,
  ) async {
    await _updatePriority(ticketId: event.ticketId, priority: event.priority);
  }

  Future<void> _onEscalateSubmitted(
    ClinicTicketEscalateSubmitted event,
    Emitter<ClinicTicketsState> emit,
  ) async {
    await _escalateTicket(ticketId: event.ticketId, staffName: event.staffName);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
