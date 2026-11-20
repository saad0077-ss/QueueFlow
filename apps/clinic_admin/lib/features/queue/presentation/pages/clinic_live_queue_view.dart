import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/layout/dashboard_chrome.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/clinic_queue_repository_impl.dart';
import '../../domain/repositories/clinic_queue_repository.dart';
import '../bloc/clinic_queue_bloc.dart';
import '../bloc/clinic_queue_event.dart';
import '../bloc/clinic_queue_state.dart';
import '../widgets/clinic_live_queue_empty_view.dart';
import '../widgets/clinic_live_queue_filter_helper.dart';
import '../widgets/clinic_live_queue_modal_helper.dart';
import '../widgets/department_queue_card.dart';
import '../widgets/queue_department_toolbar.dart';
import '../widgets/queue_header_bar.dart';
import '../widgets/queue_patient_actions_drawer.dart';
import '../widgets/queue_stats_row.dart';
import '../widgets/service_queue_detail_view.dart';

class ClinicLiveQueueView extends StatelessWidget {
  final ClinicQueueRepository? repository;
  const ClinicLiveQueueView({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? ClinicQueueRepositoryImpl();
    return BlocProvider(
      create: (_) => ClinicQueueBloc(repository: repo)..add(const QueueSubscriptionRequested()),
      child: _ClinicLiveQueueContent(repository: repo),
    );
  }
}

class _ClinicLiveQueueContent extends StatelessWidget {
  final ClinicQueueRepository repository;
  const _ClinicLiveQueueContent({required this.repository});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<ClinicQueueBloc, ClinicQueueState>(
      listener: (context, state) {
        if (state.toastMessage != null) {
          if (state.isErrorToast) {
            AppSnackBar.showError(context, message: state.toastMessage!);
          } else {
            AppSnackBar.showSuccess(context, message: state.toastMessage!);
          }
          context.read<ClinicQueueBloc>().add(const QueueClearFeedback());
        }
      },
      builder: (context, state) {
        final bloc = context.read<ClinicQueueBloc>();
        DashboardChrome.setDetailOpen('Live Queue', state.isDrillDown);

        if (state.isLoading && state.departments.isEmpty && state.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: CircularProgressIndicator(color: colors.primary),
            ),
          );
        }

        if (state.isDrillDown) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: ServiceQueueDetailView(
              service: state.drillDownService!,
              department: state.drillDownDepartment,
              allQueueItems: state.items,
              activeTab: state.serviceTab,
              onTabChanged: (tab) => bloc.add(QueueServiceTabChanged(tab)),
              onBack: () => bloc.add(const QueueDrillDownService(service: null)),
              onCallNext: () => bloc.add(QueueCallNextPressed(state.drillDownService!.name)),
              isClosed: state.summary.isServiceClosedToday(state.drillDownService!.name),
              onToggleClosed: () => bloc.add(QueueToggleServiceClosedPressed(state.drillDownService!.name)),
              onAddWalkIn: () => ClinicLiveQueueModalHelper.openAddWalkIn(context, repository, bloc, state.drillDownService!.name),
              onSelectPatient: (p) => QueuePatientActionsDrawer.show(
                context,
                patient: p,
                onCall: () => bloc.add(QueueCallSpecificPressed(p.token)),
                onComplete: () => bloc.add(QueueCompletePressed(p.token)),
                onSkip: () => bloc.add(QueueSkipPressed(p.token)),
                onRemove: () => bloc.add(QueueRemovePressed(p.token)),
              ),
              onCallSpecific: (tok) => bloc.add(QueueCallSpecificPressed(tok)),
              onComplete: (tok) => bloc.add(QueueCompletePressed(tok)),
              onSkip: (tok) => bloc.add(QueueSkipPressed(tok)),
            ),
          );
        }

        final deptsToRender = ClinicLiveQueueFilterHelper.filterAndSort(state: state);
        final activeFilterLabel = ClinicLiveQueueFilterHelper.computeActiveFilterLabel(state);
        final isAllCollapsed = state.departments.isNotEmpty && state.collapsedDepts.length == state.departments.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QueueHeaderBar(
                clinicName: state.summary.clinicName,
                isQueueOpen: state.summary.isOpen,
                onToggleQueue: () => bloc.add(const QueueTogglePausePressed()),
                onAddWalkIn: () => ClinicLiveQueueModalHelper.openAddWalkIn(context, repository, bloc),
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
                onOpenFilters: () => ClinicLiveQueueModalHelper.openFilters(context, bloc, state),
                onResetFilters: () => bloc.add(const QueueResetFilters()),
                onToggleAllDepts: () => bloc.add(const QueueToggleAllDeptsCollapsed()),
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
                    onToggleCollapse: () => bloc.add(QueueToggleDeptCollapsed(dept.id)),
                    onOpenServiceQueue: (svc) => bloc.add(QueueDrillDownService(service: svc, department: dept)),
                    onCallNextService: (svc) => bloc.add(QueueCallNextPressed(svc.name)),
                  ),
            ],
          ),
        );
      },
    );
  }
}
