import 'package:equatable/equatable.dart';

import '../../domain/entities/platform_support_ticket_entity.dart';

enum PlatformTicketsStatus { initial, loading, loaded, error }

class PlatformTicketsState extends Equatable {
  final PlatformTicketsStatus status;
  final List<PlatformSupportTicketEntity> allTickets;
  final String statusFilter;
  final String clinicFilter;
  final String categoryFilter;
  final String urgencyFilter;
  final String searchQuery;
  final String? selectedTicketId;
  final bool isViewingChat;
  final bool isMatrixView;
  final String? errorMessage;

  const PlatformTicketsState({
    this.status = PlatformTicketsStatus.initial,
    this.allTickets = const [],
    this.statusFilter = 'all',
    this.clinicFilter = 'all',
    this.categoryFilter = 'all',
    this.urgencyFilter = 'all',
    this.searchQuery = '',
    this.selectedTicketId,
    this.isViewingChat = false,
    this.isMatrixView = false,
    this.errorMessage,
  });

  int get countOpen => allTickets.where((t) => t.status == 'open').length;
  int get countInProgress =>
      allTickets.where((t) => t.status == 'in_progress').length;
  int get countResolved =>
      allTickets.where((t) => t.status == 'resolved').length;
  int get countEscalated => allTickets.where((t) => t.isEscalated).length;

  int get activeFilterCount {
    int c = 0;
    if (clinicFilter != 'all') c++;
    if (categoryFilter != 'all') c++;
    if (urgencyFilter != 'all') c++;
    return c;
  }

  List<PlatformSupportTicketEntity> get filteredTickets {
    return allTickets.where((t) {
      if (statusFilter == 'open' && t.status != 'open') return false;
      if (statusFilter == 'in_progress' && t.status != 'in_progress') {
        return false;
      }
      if (statusFilter == 'resolved' && t.status != 'resolved') return false;

      if (clinicFilter != 'all' &&
          !t.clinicName.toLowerCase().contains(clinicFilter.toLowerCase()) &&
          !t.clinicId.toLowerCase().contains(clinicFilter.toLowerCase())) {
        return false;
      }

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

      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchId = t.ticketNumber.toLowerCase().contains(q);
        final matchName = t.patientName.toLowerCase().contains(q);
        final matchClinic = t.clinicName.toLowerCase().contains(q);
        final matchSub = t.subject.toLowerCase().contains(q);
        if (!matchId && !matchName && !matchClinic && !matchSub) return false;
      }

      return true;
    }).toList();
  }

  PlatformSupportTicketEntity? get selectedTicket {
    final list = filteredTickets;
    if (list.isEmpty) return null;
    if (selectedTicketId != null) {
      for (final t in list) {
        if (t.id == selectedTicketId) return t;
      }
    }
    return list.first;
  }

  PlatformTicketsState copyWith({
    PlatformTicketsStatus? status,
    List<PlatformSupportTicketEntity>? allTickets,
    String? statusFilter,
    String? clinicFilter,
    String? categoryFilter,
    String? urgencyFilter,
    String? searchQuery,
    String? selectedTicketId,
    bool? isViewingChat,
    bool? isMatrixView,
    String? errorMessage,
  }) {
    return PlatformTicketsState(
      status: status ?? this.status,
      allTickets: allTickets ?? this.allTickets,
      statusFilter: statusFilter ?? this.statusFilter,
      clinicFilter: clinicFilter ?? this.clinicFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      urgencyFilter: urgencyFilter ?? this.urgencyFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTicketId: selectedTicketId ?? this.selectedTicketId,
      isViewingChat: isViewingChat ?? this.isViewingChat,
      isMatrixView: isMatrixView ?? this.isMatrixView,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allTickets,
    statusFilter,
    clinicFilter,
    categoryFilter,
    urgencyFilter,
    searchQuery,
    selectedTicketId,
    isViewingChat,
    isMatrixView,
    errorMessage,
  ];
}
