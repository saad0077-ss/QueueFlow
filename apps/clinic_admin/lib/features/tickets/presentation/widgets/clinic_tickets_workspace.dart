import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/clinic_pdf_exporter.dart';
import '../../data/repositories/clinic_support_repository_impl.dart';
import '../bloc/clinic_tickets_bloc.dart';
import '../bloc/clinic_tickets_event.dart';
import '../bloc/clinic_tickets_state.dart';
import 'clinic_log_ticket_dialog.dart';
import 'clinic_ticket_chat_view.dart';
import 'clinic_tickets_filter_bar.dart';
import 'clinic_tickets_filter_modal.dart';
import 'clinic_tickets_grid.dart';
import 'clinic_tickets_header.dart';
import 'clinic_tickets_kpi_cards.dart';

class ClinicTicketsWorkspace extends StatelessWidget {
  final String clinicId;
  final String clinicName;
  final String staffName;
  final int liveWaitingCount;
  final String liveNowServing;
  final VoidCallback onNavigateToQueue;

  const ClinicTicketsWorkspace({
    super.key,
    required this.clinicId,
    required this.clinicName,
    this.staffName = 'Reception Care Desk',
    this.liveWaitingCount = 0,
    this.liveNowServing = '',
    required this.onNavigateToQueue,
  });

  void _openLogTicket(BuildContext context) {
    ClinicLogTicketDialog.show(
      context,
      clinicId: clinicId,
      clinicName: clinicName,
      repository: ClinicSupportRepositoryImpl(),
      onTicketLogged: () {},
    );
  }

  void _openFilterModal(BuildContext context, ClinicTicketsState state) {
    final bloc = context.read<ClinicTicketsBloc>();
    ClinicTicketsFilterModal.show(
      context,
      initialCategory: state.categoryFilter,
      initialUrgency: state.urgencyFilter,
      initialService: state.serviceFilter,
      onApply: ({required category, required urgency, required service}) {
        bloc.add(
          ClinicTicketsModalFiltersApplied(
            category: category,
            urgency: urgency,
            service: service,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicTicketsBloc, ClinicTicketsState>(
      builder: (context, state) {
        final bloc = context.read<ClinicTicketsBloc>();
        final selected = state.selectedTicket;

        if (state.isViewingChat && selected != null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: ClinicTicketChatView(
              key: ValueKey(selected.id),
              initialTicket: selected,
              staffName: staffName,
              repository: ClinicSupportRepositoryImpl(),
              onNavigateToQueue: onNavigateToQueue,
              onBack: () => bloc.add(const ClinicTicketViewChatToggled(false)),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClinicTicketsHeader(
                clinicName: clinicName,
                onLogTicket: () => _openLogTicket(context),
                onExportPdf: () => ClinicPdfExporter.exportTickets(
                  context,
                  state.filteredTickets,
                  clinicName: clinicName,
                ),
                onSync: () => bloc.add(
                  WatchClinicTicketsStarted(
                    clinicId: clinicId,
                    clinicName: clinicName,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClinicTicketsKpiCards(
                totalCount: state.countAll,
                openCount: state.countOpen,
                inProgressCount: state.countInProgress,
                resolvedCount: state.countResolved,
              ),
              const SizedBox(height: 16),
              ClinicTicketsFilterBar(
                searchQuery: state.searchQuery,
                onSearchChanged: (q) => bloc.add(ClinicTicketsSearchChanged(q)),
                onOpenFilters: () => _openFilterModal(context, state),
                activeFilterCount: state.activeFilterCount,
                selectedStatus: state.statusFilter,
                onStatusChanged: (s) =>
                    bloc.add(ClinicTicketsStatusFilterChanged(s)),
                countAll: state.countAll,
                countOpen: state.countOpen,
                countInProgress: state.countInProgress,
                countResolved: state.countResolved,
              ),
              const SizedBox(height: 16),
              ClinicTicketsGrid(
                tickets: state.filteredTickets,
                selectedTicketId: state.selectedTicketId,
                onSelectTicket: (id) {
                  bloc.add(ClinicTicketSelected(id));
                  bloc.add(const ClinicTicketViewChatToggled(true));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
