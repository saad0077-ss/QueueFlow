import '../../../../core/layout/dashboard_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/clinic_doctors_repository_impl.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/usecases/call_next_patient_usecase.dart';
import '../../domain/usecases/delete_clinic_doctor_usecase.dart';
import '../../domain/usecases/get_clinic_doctors_usecase.dart';
import '../../domain/usecases/save_clinic_doctor_usecase.dart';
import '../../domain/usecases/update_doctor_status_usecase.dart';
import '../bloc/clinic_doctors_bloc.dart';
import '../bloc/clinic_doctors_event.dart';
import '../bloc/clinic_doctors_state.dart';
import '../widgets/add_doctor_dialog.dart';
import '../widgets/doctor_capacity_quota_card.dart';
import '../widgets/doctor_detail_view.dart';
import '../widgets/doctors_cards_grid.dart';
import '../widgets/doctors_roster_header.dart';
import '../widgets/doctors_view_header.dart';   

class ClinicDoctorsView extends StatelessWidget {
  final VoidCallback? onNavigateToBilling;
  final VoidCallback? onNavigateToQueue;   
 
  const ClinicDoctorsView({
    super.key,  
    this.onNavigateToBilling,
    this.onNavigateToQueue,
  });

  @override
  Widget build(BuildContext context) {
    final repo = ClinicDoctorsRepositoryImpl();

    return BlocProvider(
      create: (_) => ClinicDoctorsBloc(
        getDoctorsUseCase: GetClinicDoctorsUseCase(repo),
        saveDoctorUseCase: SaveClinicDoctorUseCase(repo),
        updateDoctorStatusUseCase: UpdateDoctorStatusUseCase(repo),
        deleteDoctorUseCase: DeleteClinicDoctorUseCase(repo),
        callNextPatientUseCase: CallNextPatientUseCase(repo),
        repository: repo,
      )..add(const DoctorsSubscriptionRequested()),
      child: _ClinicDoctorsBody(
        onNavigateToBilling: onNavigateToBilling,
        onNavigateToQueue: onNavigateToQueue,
      ),
    );
  }
}

class _ClinicDoctorsBody extends StatelessWidget {
  final VoidCallback? onNavigateToBilling;
  final VoidCallback? onNavigateToQueue;

  const _ClinicDoctorsBody({
    this.onNavigateToBilling,
    this.onNavigateToQueue,
  });

  void _openAddDoctorModal(BuildContext context, ClinicDoctorsState state) {
    if (state.isLimitReached) {
      AppSnackBar.showError(
        context,
        message:
            'Doctor capacity reached (${state.doctors.length}/${state.plan.doctorsLimit}). Please upgrade your plan in Plan & Billing to add more doctors.',
      );
      return;
    }

    AddDoctorDialog.show(
      context,
      departments: state.departments,
      onSave: (doc) {
        context.read<ClinicDoctorsBloc>().add(DoctorAddSubmitted(doc));
      },
    );
  }

  void _confirmDeleteDoctor(
    BuildContext context,
    ClinicDoctorProfileEntity doctor,
  ) {
    final colors = context.colors;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.border),
        ),
        title: Text(
          'Remove Doctor',
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to remove ${doctor.name} from the practicing roster?',
          style: TextStyle(color: colors.textMuted, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ClinicDoctorsBloc>().add(
                    DoctorDeletePressed(
                      doctorId: doctor.id,
                      doctorName: doctor.name,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicDoctorsBloc, ClinicDoctorsState>(
      listener: (context, state) {
        if (state.toastMessage != null) {
          if (state.isErrorToast) {
            AppSnackBar.showError(context, message: state.toastMessage!);
          } else {
            AppSnackBar.showSuccess(context, message: state.toastMessage!);
          }
          context.read<ClinicDoctorsBloc>().add(const DoctorsClearToast());
        }
      },
      builder: (context, state) {
        final bloc = context.read<ClinicDoctorsBloc>();
        DashboardChrome.setDetailOpen('Doctors', state.selectedDoctor != null);

        if (state.selectedDoctor != null) {
          return DoctorDetailView(
            doctor: state.selectedDoctor!,
            departments: state.departments,
            onBack: () => bloc.add(const DoctorSelected(null)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DoctorsViewHeader(
              planPill: state.plan.planPill,
              planName: state.plan.planName,
              onAddDoctor: () => _openAddDoctorModal(context, state),
            ),
            const SizedBox(height: 18),
            DoctorCapacityQuotaCard(
              currentCount: state.doctors.length,
              plan: state.plan,
              onUpgrade: () {
                if (onNavigateToBilling != null) {
                  onNavigateToBilling!();
                } else {
                  AppSnackBar.showInfo(context, message: 'Navigating to Plan & Billing...');
                }
              },
            ),
            const SizedBox(height: 22),
            DoctorsRosterHeader(count: state.doctors.length),
            const SizedBox(height: 14),
            if (state.status == DoctorsStatus.initial ||
                state.status == DoctorsStatus.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                ),
              )
            else
              DoctorsCardsGrid(
                doctors: state.doctors,
                plan: state.plan,
                onCallNext: (doc) => bloc.add(DoctorCallNextPressed(doc.name)),
                onSelectDoctor: (doc) => bloc.add(DoctorSelected(doc)),
                onViewQueue: (doc) {
                  if (onNavigateToQueue != null) {
                    onNavigateToQueue!();
                  } else {
                    AppSnackBar.showInfo(
                      context,
                      message: 'Opening Live Queue for ${doc.name}...',
                    );
                  }
                },
                onStatusChange: (doc, status) => bloc.add(
                  DoctorStatusChanged(doctorId: doc.id, status: status),
                ),
                onDelete: (doc) => _confirmDeleteDoctor(context, doc),
                onAddDoctor: () => _openAddDoctorModal(context, state),
                onUpgradePlan: () {
                  if (onNavigateToBilling != null) {
                    onNavigateToBilling!();
                  } else {
                    AppSnackBar.showInfo(
                      context,
                      message: 'Navigating to Plan & Billing...',
                    );
                  }
                },
              ),
          ],
        );
      },
    );
  }
}
