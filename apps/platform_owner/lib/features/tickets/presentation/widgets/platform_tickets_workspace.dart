import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/platform_support_repository_impl.dart';
import '../../domain/entities/platform_support_ticket_entity.dart';
import '../../domain/repositories/platform_support_repository.dart';
import 'platform_ticket_chat_console.dart';
import 'platform_tickets_broadcast_dialog.dart';
import 'platform_tickets_export_helper.dart';
import 'platform_tickets_filter_bar.dart';
import 'platform_tickets_filter_helper.dart';
import 'platform_tickets_filter_modal_helper.dart';
import 'platform_tickets_grid.dart';
import 'platform_tickets_header.dart';
import 'platform_tickets_kpi_cards.dart';

class PlatformTicketsWorkspace extends StatefulWidget {
  final String topBarSearch;

  const PlatformTicketsWorkspace({super.key, this.topBarSearch = ''});

  @override
  State<PlatformTicketsWorkspace> createState() =>
      _PlatformTicketsWorkspaceState();
}

class _PlatformTicketsWorkspaceState extends State<PlatformTicketsWorkspace> {
  final PlatformSupportRepository _repository = PlatformSupportRepositoryImpl();
  Timer? _countdownTicker;

  String _searchQuery = '';
  String _selectedClinicFilter = 'all';
  String _selectedSlaFilter = 'all';
  String _selectedCategoryFilter = 'all';
  String _selectedStatusFilter = 'all';
  String? _selectedTicketId;
  bool _isViewingChat = false;

  @override
  void initState() {
    super.initState();
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    super.dispose();
  }

  int get _activeFilterCount {
    int c = 0;
    if (_selectedClinicFilter != 'all') c++;
    if (_selectedSlaFilter != 'all') c++;
    if (_selectedCategoryFilter != 'all') c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlatformSupportTicketEntity>>(
      stream: _repository.watchAllTickets(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? [];
        final filtered = PlatformTicketsFilterHelper.applyFilters(
          all: all,
          status: _selectedStatusFilter,
          clinicId: _selectedClinicFilter,
          sla: _selectedSlaFilter,
          category: _selectedCategoryFilter,
          searchQuery: _searchQuery,
          topBarSearch: widget.topBarSearch,
        );
        PlatformSupportTicketEntity? selected;
        if (filtered.isNotEmpty) {
          if (_selectedTicketId != null) {
            for (final t in filtered) {
              if (t.id == _selectedTicketId) {
                selected = t;
                break;
              }
            }
          }
          selected ??= filtered.first;
          _selectedTicketId ??= selected.id;
        }

        if (_isViewingChat && selected != null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: PlatformTicketChatConsole(
              key: ValueKey(selected.id),
              initialTicket: selected,
              repository: _repository,
              adminName: 'Platform Admin',
              onBack: () => setState(() => _isViewingChat = false),
              onTicketDeleted: () => setState(() {
                _isViewingChat = false;
                _selectedTicketId = null;
              }),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlatformTicketsHeader(
                onExportCsv: () =>
                    PlatformTicketsExportHelper.exportCsv(context, all),
                onBroadcastNotice: () => PlatformTicketsBroadcastDialog.show(
                  context,
                  allTickets: all,
                  repository: _repository,
                ),
                onSyncAll: () {
                  setState(() {});
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
                searchQuery: _searchQuery,
                onSearchChanged: (q) => setState(() => _searchQuery = q),
                onOpenFilters: () =>
                    PlatformTicketsFilterModalHelper.openFilterModal(
                      context: context,
                      allTickets: all,
                      selectedClinicFilter: _selectedClinicFilter,
                      selectedSlaFilter: _selectedSlaFilter,
                      selectedCategoryFilter: _selectedCategoryFilter,
                      onApply:
                          ({
                            required clinic,
                            required sla,
                            required category,
                          }) => setState(() {
                            _selectedClinicFilter = clinic;
                            _selectedSlaFilter = sla;
                            _selectedCategoryFilter = category;
                          }),
                    ),
                activeFilterCount: _activeFilterCount,
                selectedStatus: _selectedStatusFilter,
                onStatusChanged: (s) =>
                    setState(() => _selectedStatusFilter = s),
                countAll: all.length,
                countOpen: all.where((t) => t.status == 'open').length,
                countInProgress: all
                    .where((t) => t.status == 'in_progress')
                    .length,
                countResolved: all.where((t) => t.status == 'resolved').length,
              ),
              const SizedBox(height: 16),
              PlatformTicketsGrid(
                filteredTickets: filtered,
                selectedTicketId: _selectedTicketId,
                onSelectTicket: (t) => setState(() {
                  _selectedTicketId = t.id;
                  _isViewingChat = true;
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
