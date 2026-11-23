import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_support_ticket_entity.dart';

enum ClinicTicketsStatus { initial, loading, loaded, error }

class ClinicTicketsState extends Equatable {
  final ClinicTicketsStatus status;
  final List<ClinicSupportTicketEntity> allTickets;
  final String statusFilter;
  final String categoryFilter;
  final String urgencyFilter;
  final String serviceFilter;
  final String searchQuery;
  final String? selectedTicketId;
  final bool isViewingChat;
  final String? errorMessage;

  const ClinicTicketsState({
    this.status = ClinicTicketsStatus.initial,
    this.allTickets = const [],
    this.statusFilter = 'all',
    this.categoryFilter = 'all',
    this.urgencyFilter = 'all',
    this.serviceFilter = 'all',
    this.searchQuery = '',
    this.selectedTicketId,
    this.isViewingChat = false,
    this.errorMessage,
  });

  static bool _isClinicTicket(ClinicSupportTicketEntity t) {
    return t.isClinicRelated &&
        t.category.toLowerCase() != 'technical' &&
        !t.category.toLowerCase().contains('bug') &&
        t.clinicId != 'platform';
  }

  int get countOpen =>
      allTickets.where((t) => _isClinicTicket(t) && t.status == 'open').length;
  int get countInProgress => allTickets
      .where((t) => _isClinicTicket(t) && t.status == 'in_progress')
      .length;
  int get countResolved => allTickets
      .where((t) => _isClinicTicket(t) && t.status == 'resolved')
      .length;

  int get activeFilterCount {
    int c = 0;
    if (categoryFilter != 'all') c++;
    if (urgencyFilter != 'all') c++;
    if (serviceFilter != 'all') c++;
    return c;
  }

  List<ClinicSupportTicketEntity> get filteredTickets {
    return allTickets.where((t) {
      if (!_isClinicTicket(t)) return false;
      if (statusFilter == 'open' && t.status != 'open') return false;
      if (statusFilter == 'in_progress' && t.status != 'in_progress') {
        return false;
      }
      if (statusFilter == 'resolved' && t.status != 'resolved') return false;

      if (categoryFilter != 'all' &&
          !t.category.toLowerCase().contains(categoryFilter.toLowerCase())) {
        return false;
      }

      if (urgencyFilter == 'urgent' &&
          (t.slaMinutes >= 15 && t.priority != 'high')) {
        return false;
      } else if (urgencyFilter == 'high' && t.priority != 'high') {
        return false;
      }

      if (serviceFilter != 'all' &&
          !t.subject.toLowerCase().contains(serviceFilter.toLowerCase()) &&
          !t.description.toLowerCase().contains(serviceFilter.toLowerCase())) {
        return false;
      }

      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchId = t.ticketNumber.toLowerCase().contains(q);
        final matchName = t.patientName.toLowerCase().contains(q);
        final matchToken =
            t.linkedTokenNumber != null &&
            t.linkedTokenNumber!.toLowerCase().contains(q);
        final matchSub = t.subject.toLowerCase().contains(q);
        if (!matchId && !matchName && !matchToken && !matchSub) return false;
      }

      return true;
    }).toList();
  }

  ClinicSupportTicketEntity? get selectedTicket {
    final list = filteredTickets;
    if (list.isEmpty) return null;
    if (selectedTicketId != null) {
      for (final t in list) {
        if (t.id == selectedTicketId) return t;
      }
    }
    return list.first;
  }

  ClinicTicketsState copyWith({
    ClinicTicketsStatus? status,
    List<ClinicSupportTicketEntity>? allTickets,
    String? statusFilter,
    String? categoryFilter,
    String? urgencyFilter,
    String? serviceFilter,
    String? searchQuery,
    String? selectedTicketId,
    bool? isViewingChat,
    String? errorMessage,
  }) {
    return ClinicTicketsState(
      status: status ?? this.status,
      allTickets: allTickets ?? this.allTickets,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      urgencyFilter: urgencyFilter ?? this.urgencyFilter,
      serviceFilter: serviceFilter ?? this.serviceFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTicketId: selectedTicketId ?? this.selectedTicketId,
      isViewingChat: isViewingChat ?? this.isViewingChat,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allTickets,
    statusFilter,
    categoryFilter,
    urgencyFilter,
    serviceFilter,
    searchQuery,
    selectedTicketId,
    isViewingChat,
    errorMessage,
  ];
}
