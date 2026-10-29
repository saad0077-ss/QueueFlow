import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import '../bloc/clinics_directory_bloc.dart';
import '../bloc/clinics_directory_event.dart';
import '../bloc/clinics_directory_state.dart';
import '../../../departments/domain/entities/department_entity.dart';
import 'clinics_data_table.dart';
import 'clinics_filter_row.dart';
import 'clinics_header_bar.dart';
import 'clinics_kpi_cards.dart';
import 'delete_clinic_dialog.dart';
import 'edit_clinic_modal.dart';
import 'manage_subscription_modal.dart';
import 'onboard_clinic_modal.dart';

class ClinicsDirectoryContent extends StatelessWidget {
  final bool isDesktop;
  final ClinicsDirectoryState state;
  final Map<String, int> appointments;
  final List<DepartmentEntity> departments;
  final TenantRepositoryImpl repo;
  final ValueChanged<TenantClinicEntity> onDetails;
  final void Function(TenantClinicEntity) onResendInvite;
  final VoidCallback onClinicDeleted;

  const ClinicsDirectoryContent({
    super.key,
    required this.isDesktop,
    required this.state,
    required this.appointments,
    required this.departments,
    required this.repo,
    required this.onDetails,
    required this.onResendInvite,
    required this.onClinicDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 14.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClinicsHeaderBar(
            onExportCsv: () => AppSnackBar.showInfo(context, message: 'Exported clinics to CSV.'),
            onRefresh: () => AppSnackBar.showSuccess(context, message: 'Clinics refreshed.'),
            onOnboard: () => OnboardClinicModal.show(context),
            activeCount: state.activePractices,
            totalCount: state.totalClinics,
          ),
          const SizedBox(height: 18),
          ClinicsKpiCards(
            totalClinics: state.totalClinics,
            activePractices: state.activePractices,
            invitedClinics: state.invitedClinics,
            totalDoctors: state.totalDoctors,
            appointmentsMonth: state.allClinics.fold(0, (total, c) => total + (appointments[c.id] ?? 0)),
            totalMrr: state.totalMrr,
          ),
          const SizedBox(height: 18),
          ClinicsFilterRow(
            searchQuery: state.searchQuery,
            selectedPlan: state.selectedPlanFilter,
            selectedStatus: state.selectedStatusFilter,
            count: state.filteredClinics.length,
            total: state.totalClinics,
            onSearch: (q) => context.read<ClinicsDirectoryBloc>().add(ClinicsSearchQueryChanged(q)),
            onPlanChanged: (p) => context.read<ClinicsDirectoryBloc>().add(ClinicsPlanFilterChanged(p)),
            onStatusChanged: (s) => context.read<ClinicsDirectoryBloc>().add(ClinicsStatusFilterChanged(s)),
            onReset: () => context.read<ClinicsDirectoryBloc>().add(const ClinicsResetFilters()),
          ),
          const SizedBox(height: 18),
          ClinicsDataTable(
            departments: departments,
            clinics: state.filteredClinics,
            appointmentsByClinic: appointments,
            onDetails: onDetails,
            onEdit: (c) => EditClinicModal.show(context, c),
            onManagePlan: (c) => ManageSubscriptionModal.show(context, c),
            onToggleStatus: (c) async {
              try {
                await repo.toggleStatus(c.id, c.isActive);
                if (context.mounted) AppSnackBar.showSuccess(context, message: c.isActive ? 'Clinic paused.' : 'Clinic activated.');
              } catch (e) {
                if (context.mounted) AppSnackBar.showWarning(context, message: e.toString().replaceFirst('Exception: ', ''));
              }
            },
            onResendInvite: onResendInvite,
            onDelete: (c) => DeleteClinicDialog.show(context, c, repo, onDeleted: onClinicDeleted),
          ),
        ],
      ),
    );
  }
}
