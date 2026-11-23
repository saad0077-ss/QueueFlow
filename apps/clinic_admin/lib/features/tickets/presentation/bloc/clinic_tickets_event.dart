import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_support_ticket_entity.dart';

abstract class ClinicTicketsEvent extends Equatable {
  const ClinicTicketsEvent();

  @override
  List<Object?> get props => [];
}

class WatchClinicTicketsStarted extends ClinicTicketsEvent {
  final String clinicId;
  final String? clinicName;

  const WatchClinicTicketsStarted({required this.clinicId, this.clinicName});

  @override
  List<Object?> get props => [clinicId, clinicName];
}

class ClinicTicketsUpdated extends ClinicTicketsEvent {
  final List<ClinicSupportTicketEntity> tickets;

  const ClinicTicketsUpdated(this.tickets);

  @override
  List<Object?> get props => [tickets];
}

class ClinicTicketsStatusFilterChanged extends ClinicTicketsEvent {
  final String status;

  const ClinicTicketsStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class ClinicTicketsModalFiltersApplied extends ClinicTicketsEvent {
  final String category;
  final String urgency;
  final String service;

  const ClinicTicketsModalFiltersApplied({
    required this.category,
    required this.urgency,
    required this.service,
  });

  @override
  List<Object?> get props => [category, urgency, service];
}

class ClinicTicketsSearchChanged extends ClinicTicketsEvent {
  final String query;

  const ClinicTicketsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ClinicTicketSelected extends ClinicTicketsEvent {
  final String? ticketId;

  const ClinicTicketSelected(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class ClinicTicketViewChatToggled extends ClinicTicketsEvent {
  final bool isViewing;

  const ClinicTicketViewChatToggled(this.isViewing);

  @override
  List<Object?> get props => [isViewing];
}

class ClinicTicketReplySubmitted extends ClinicTicketsEvent {
  final String ticketId;
  final String text;
  final String staffName;
  final bool isInternalNote;

  const ClinicTicketReplySubmitted({
    required this.ticketId,
    required this.text,
    required this.staffName,
    this.isInternalNote = false,
  });

  @override
  List<Object?> get props => [ticketId, text, staffName, isInternalNote];
}

class ClinicTicketStatusSubmitted extends ClinicTicketsEvent {
  final String ticketId;
  final String status;
  final String staffName;

  const ClinicTicketStatusSubmitted({
    required this.ticketId,
    required this.status,
    this.staffName = 'Clinic Admin',
  });

  @override
  List<Object?> get props => [ticketId, status, staffName];
}

class ClinicTicketPrioritySubmitted extends ClinicTicketsEvent {
  final String ticketId;
  final String priority;

  const ClinicTicketPrioritySubmitted({
    required this.ticketId,
    required this.priority,
  });

  @override
  List<Object?> get props => [ticketId, priority];
}

class ClinicTicketEscalateSubmitted extends ClinicTicketsEvent {
  final String ticketId;
  final String staffName;

  const ClinicTicketEscalateSubmitted({
    required this.ticketId,
    required this.staffName,
  });

  @override
  List<Object?> get props => [ticketId, staffName];
}
