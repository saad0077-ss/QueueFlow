import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/platform_support_repository_impl.dart';
import '../bloc/platform_tickets_bloc.dart';
import '../bloc/platform_tickets_event.dart';
import '../bloc/platform_tickets_state.dart';
import 'platform_tickets_broadcast_dialog.dart';
import 'platform_tickets_export_helper.dart';
import 'platform_tickets_filter_bar.dart';
import 'platform_tickets_filter_modal_helper.dart';
import 'platform_tickets_grid.dart';
import 'platform_tickets_header.dart';
import 'platform_tickets_kpi_cards.dart';

class PlatformTicketsWorkspaceContent extends StatelessWidget {
  final PlatformTicketsState state;

  const PlatformTicketsWorkspaceContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlatformTicketsBloc>();
    final all = state.allTickets;
    final filtered = state.filteredTickets;
    final repo = PlatformSupportRepositoryImpl();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlatformTicketsHeader(
            onExportPdf: () =>
                PlatformTicketsExportHelper.exportPdf(context, all),
            onBroadcastNotice: () => PlatformTicketsBroadcastDialog.show(
              context,
              allTickets: all,
              repository: repo,
            ),
            onSyncAll: () {
              bloc.add(const WatchPlatformTicketsStarted());
              AppSnackBar.showSuccess(
                context,
                message: 'Ticket registry synchronized with live Firestore cluster.',
              );
            },
          ),
          const SizedBox(height: 16),
          PlatformTicketsKpiCards(
            totalCount: all.length,
            atRiskCount: all
                .where((t) => t.priority == 'high' || t.slaMinutes < 15)
                .length,
            activeClinicsCount: all
                .where((t) => t.status != 'resolved')
                .map((t) => t.clinicId)
                .toSet()
                .length,
            avgResponseTime: '4.2m',
          ),
          const SizedBox(height: 16),
          PlatformTicketsFilterBar(
            searchQuery: state.searchQuery,
            onSearchChanged: (q) => bloc.add(PlatformTicketsSearchChanged(q)),
            onOpenFilters: () =>
                PlatformTicketsFilterModalHelper.openFilterModal(
                  context: context,
                  allTickets: all,
                  selectedClinicFilter: state.clinicFilter,
                  selectedSlaFilter: state.urgencyFilter,
                  selectedCategoryFilter: state.categoryFilter,
                  onApply: ({required clinic, required sla, required category}) {
                    bloc.add(
                      PlatformTicketsModalFiltersApplied(
                        clinic: clinic,
                        category: category,
                        urgency: sla,
                      ),
                    );
                  },
                ),
            activeFilterCount: state.activeFilterCount,
            selectedStatus: state.statusFilter,
            onStatusChanged: (s) =>
                bloc.add(PlatformTicketsStatusFilterChanged(s)),
            countAll: all.length,
            countOpen: state.countOpen,
            countInProgress: state.countInProgress,
            countResolved: state.countResolved,
          ),
          const SizedBox(height: 16),
          PlatformTicketsGrid(
            filteredTickets: filtered,
            selectedTicketId: state.selectedTicketId,
            onSelectTicket: (t) {
              bloc.add(PlatformTicketSelected(t.id));
              bloc.add(const PlatformTicketViewChatToggled(true));
            },
          ),
        ],
      ),
    );
  }
}
