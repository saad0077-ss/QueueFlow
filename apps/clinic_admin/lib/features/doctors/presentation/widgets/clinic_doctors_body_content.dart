import 'package:flutter/material.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../bloc/clinic_doctors_bloc.dart';
import '../bloc/clinic_doctors_event.dart';
import '../bloc/clinic_doctors_state.dart';
import 'clinic_doctors_dialog_helper.dart';
import 'doctor_capacity_quota_card.dart';
import 'doctors_cards_grid.dart';
import 'doctors_roster_header.dart';
import 'doctors_view_header.dart';

class ClinicDoctorsBodyContent extends StatelessWidget {
  final ClinicDoctorsState state;
  final ClinicDoctorsBloc bloc;
  final VoidCallback? onNavigateToBilling;
  final VoidCallback? onNavigateToQueue;

  const ClinicDoctorsBodyContent({
    super.key,
    required this.state,
    required this.bloc,
    this.onNavigateToBilling,
    this.onNavigateToQueue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DoctorsViewHeader(
          planPill: state.plan.planPill,
          planName: state.plan.planName,
          onAddDoctor: () =>
              ClinicDoctorsDialogHelper.openAddDoctorModal(context, state),
        ),
        const SizedBox(height: 18),
        DoctorCapacityQuotaCard(
          currentCount: state.doctors.length,
          plan: state.plan,
          onUpgrade: () {
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
            onStatusChange: (doc, status) =>
                bloc.add(DoctorStatusChanged(doctorId: doc.id, status: status)),
            onDelete: (doc) =>
                ClinicDoctorsDialogHelper.confirmDeleteDoctor(context, doc),
            onAddDoctor: () =>
                ClinicDoctorsDialogHelper.openAddDoctorModal(context, state),
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
  }
}
