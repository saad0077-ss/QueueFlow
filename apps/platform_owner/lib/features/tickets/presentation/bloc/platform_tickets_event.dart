import 'package:equatable/equatable.dart';

import '../../domain/entities/platform_support_ticket_entity.dart';

abstract class PlatformTicketsEvent extends Equatable {
  const PlatformTicketsEvent();

  @override
  List<Object?> get props => [];
}

class WatchPlatformTicketsStarted extends PlatformTicketsEvent {
  const WatchPlatformTicketsStarted();
}

class PlatformTicketsUpdated extends PlatformTicketsEvent {
  final List<PlatformSupportTicketEntity> tickets;
  const PlatformTicketsUpdated(this.tickets);

  @override
  List<Object?> get props => [tickets];
}

class PlatformTicketsStatusFilterChanged extends PlatformTicketsEvent {
  final String status;
  const PlatformTicketsStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class PlatformTicketsModalFiltersApplied extends PlatformTicketsEvent {
  final String clinic;
  final String category;
  final String urgency;

  const PlatformTicketsModalFiltersApplied({
    required this.clinic,
    required this.category,
    required this.urgency,
  });

  @override
  List<Object?> get props => [clinic, category, urgency];
}

class PlatformTicketsSearchChanged extends PlatformTicketsEvent {
  final String query;
  const PlatformTicketsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class PlatformTicketSelected extends PlatformTicketsEvent {
  final String? ticketId;
  const PlatformTicketSelected(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class PlatformTicketViewChatToggled extends PlatformTicketsEvent {
  final bool isViewing;
  const PlatformTicketViewChatToggled(this.isViewing);

  @override
  List<Object?> get props => [isViewing];
}

class PlatformTicketViewModeToggled extends PlatformTicketsEvent {
  final bool isMatrixView;
  const PlatformTicketViewModeToggled(this.isMatrixView);

  @override
  List<Object?> get props => [isMatrixView];
}

class PlatformTicketReplySubmitted extends PlatformTicketsEvent {
  final String ticketId;
  final String text;
  final String senderName;
  final bool isInternalNote;

  const PlatformTicketReplySubmitted({
    required this.ticketId,
    required this.text,
    required this.senderName,
    this.isInternalNote = false,
  });

  @override
  List<Object?> get props => [ticketId, text, senderName, isInternalNote];
}

class PlatformTicketStatusSubmitted extends PlatformTicketsEvent {
  final String ticketId;
  final String status;
  final String staffName;

  const PlatformTicketStatusSubmitted({
    required this.ticketId,
    required this.status,
    this.staffName = 'Platform Admin',
  });

  @override
  List<Object?> get props => [ticketId, status, staffName];
}

class PlatformTicketPrioritySubmitted extends PlatformTicketsEvent {
  final String ticketId;
  final String priority;

  const PlatformTicketPrioritySubmitted({
    required this.ticketId,
    required this.priority,
  });

  @override
  List<Object?> get props => [ticketId, priority];
}

class PlatformTicketDeleteSubmitted extends PlatformTicketsEvent {
  final String ticketId;
  const PlatformTicketDeleteSubmitted(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}
