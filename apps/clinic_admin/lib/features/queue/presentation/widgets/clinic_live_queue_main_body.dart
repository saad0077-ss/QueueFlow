import 'package:flutter/material.dart';
import '../../domain/repositories/clinic_queue_repository.dart';
import '../bloc/clinic_queue_bloc.dart';
import '../bloc/clinic_queue_event.dart';
import '../bloc/clinic_queue_state.dart';
import 'clinic_live_queue_empty_view.dart';
import 'clinic_live_queue_filter_helper.dart';
import 'clinic_live_queue_modal_helper.dart';
import 'department_queue_card.dart';
import 'queue_department_toolbar.dart';
import 'queue_header_bar.dart';
import 'queue_stats_row.dart';

class ClinicLiveQueueMainBody extends StatelessWidget {
  final ClinicQueueRepository repository;
  final ClinicQueueBloc bloc;
  final ClinicQueueState state;

  const ClinicLiveQueueMainBody({
    super.key,
    required this.repository,
    required this.bloc,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final deptsToRender = ClinicLiveQueueFilterHelper.filterAndSort(
      state: state,
    );
    final activeFilterLabel =
        ClinicLiveQueueFilterHelper.computeActiveFilterLabel(state);
    final isAllCollapsed =
        state.departments.isNotEmpty &&
        state.collapsedDepts.length == state.departments.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QueueHeaderBar(
            clinicName: state.summary.clinicName,
            isQueueOpen: state.summary.isOpen,
            onToggleQueue: () => bloc.add(const QueueTogglePausePressed()),
            onAddWalkIn: () => ClinicLiveQueueModalHelper.openAddWalkIn(
              context,
              repository,
              bloc,
            ),
          ),
          const SizedBox(height: 18),
          QueueStatsRow(
            totalDepartments: state.departments.length,
            totalServices: state.services.length,
            waitingCount: state.waitingCount,
            avgWaitTime: state.summary.avgWaitTime,
          ),
          const SizedBox(height: 18),
          QueueDepartmentToolbar(
            searchQuery: state.searchQuery,
            activeFiltersCount: state.activeFiltersCount,
            activeFilterLabel: activeFilterLabel,
            isAllCollapsed: isAllCollapsed,
            onSearchChanged: (q) => bloc.add(QueueSearchChanged(q)),
            onClearSearch: () => bloc.add(const QueueSearchChanged('')),
            onOpenFilters: () =>
                ClinicLiveQueueModalHelper.openFilters(context, bloc, state),
            onResetFilters: () => bloc.add(const QueueResetFilters()),
            onToggleAllDepts: () =>
                bloc.add(const QueueToggleAllDeptsCollapsed()),
          ),
          const SizedBox(height: 20),
          if (deptsToRender.isEmpty)
            ClinicLiveQueueEmptyView(
              searchQuery: state.searchQuery,
              hasActiveFilters: state.activeFiltersCount > 0,
              onResetFilters: () => bloc.add(const QueueResetFilters()),
            )
          else
            for (final dept in deptsToRender)
              DepartmentQueueCard(
                department: dept,
                services: state.servicesForDepartment(dept.id, dept.name),
                queueItems: state.items,
                isCollapsed: state.collapsedDepts.contains(dept.id),
                isQueueOpen: state.summary.isOpen,
                onToggleCollapse: () =>
                    bloc.add(QueueToggleDeptCollapsed(dept.id)),
                onOpenServiceQueue: (svc) => bloc.add(
                  QueueDrillDownService(service: svc, department: dept),
                ),
                onCallNextService: (svc) =>
                    bloc.add(QueueCallNextPressed(svc.name)),
              ),
        ],
      ),
    );
  }
}
