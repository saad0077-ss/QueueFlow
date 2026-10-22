import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/repositories/department_repository.dart';
import '../bloc/departments_bloc.dart';
import '../bloc/departments_event.dart';
import '../bloc/departments_state.dart';
import 'add_department_modal.dart';
import 'department_approval_queue.dart';
import 'departments_data_table.dart';
import 'departments_filter_row.dart';
import 'departments_header_bar.dart';
import 'departments_kpi_cards.dart';
import 'dept_delete_dialog.dart';

class DeptContentView extends StatelessWidget {
  final DepartmentRepository repository;
  final ValueChanged<DepartmentEntity> onDetails;

  const DeptContentView({super.key, required this.repository, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepartmentsBloc, DepartmentsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DepartmentsHeaderBar(
                activeCount: state.activeDepartments,
                onExportCsv: () => AppSnackBar.showInfo(context, message: 'Exported departments CSV.'),
                onRefresh: () => AppSnackBar.showSuccess(context, message: 'Departments refreshed.'),
                onAddDepartment: () => AddDepartmentModal.show(
                  context,
                  (d) => repository.addDepartment(d),
                  existingDepartments: state.allDepartments,
                ),
              ),
              const SizedBox(height: 18),
              DepartmentsKpiCards(
                totalDepartments: state.totalDepartments,
                activeSpecialties: state.activeDepartments,
                doctorsAssigned: state.totalDoctors,
                monthlyVisits: state.totalMonthlyVisits,
              ),
              if (state.pendingExpansionRequests.isNotEmpty || state.pendingServiceRequests.isNotEmpty) ...[
                const SizedBox(height: 18),
                DepartmentApprovalQueue(
                  expansionRequests: state.pendingExpansionRequests,
                  serviceRequests: state.pendingServiceRequests,
                  onApproveExpansion: (r) async {
                    await repository.approveExpansionRequest(r.id);
                    if (context.mounted) AppSnackBar.showSuccess(context, message: 'Approved expansion for "${r.clinicName}".');
                  },
                  onRejectExpansion: (r) async {
                    await repository.rejectExpansionRequest(r.id, 'Capacity limit.');
                    if (context.mounted) AppSnackBar.showWarning(context, message: 'Request rejected.');
                  },
                  onApproveService: (s) async {
                    await repository.approveServiceRequest(s.id);
                    if (context.mounted) AppSnackBar.showSuccess(context, message: 'Approved "${s.serviceName}".');
                  },
                  onRejectService: (s) async {
                    await repository.rejectServiceRequest(s.id, 'Standard catalog guidelines.');
                    if (context.mounted) AppSnackBar.showWarning(context, message: 'Service rejected.');
                  },
                ),
              ],
              const SizedBox(height: 18),
              DepartmentsFilterRow(
                searchQuery: state.searchQuery,
                selectedStatus: state.selectedStatusFilter,
                selectedClinic: state.selectedClinicFilter,
                count: state.filteredDepartments.length,
                total: state.totalDepartments,
                onSearch: (q) => context.read<DepartmentsBloc>().add(DepartmentSearchQueryChanged(q)),
                onStatusChanged: (s) => context.read<DepartmentsBloc>().add(DepartmentStatusFilterChanged(s)),
                onClinicChanged: (c) => context.read<DepartmentsBloc>().add(DepartmentClinicFilterChanged(c)),
                onReset: () => context.read<DepartmentsBloc>().add(const DepartmentsResetFilters()),
              ),
              const SizedBox(height: 18),
              DepartmentsDataTable(
                departments: state.filteredDepartments,
                onDetails: onDetails,
                onEdit: (d) => AddDepartmentModal.show(
                  context,
                  (up) async {
                    await repository.updateDepartment(up);
                    if (context.mounted) AppSnackBar.showSuccess(context, message: 'Updated "${up.name}".');
                  },
                  existingDepartments: state.allDepartments,
                  initial: d,
                ),
                onToggleStatus: (d) => repository.toggleDepartmentStatus(d.id, d.isActive),
                onDelete: (d) => DeptDeleteDialog.show(context, d, () => repository.deleteDepartment(d.id)),
              ),
            ],
          ),
        );
      },
    );
  }
}
