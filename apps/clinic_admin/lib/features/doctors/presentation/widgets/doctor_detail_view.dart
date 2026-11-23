import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/entities/doctor_daily_schedule.dart';
import '../bloc/clinic_doctors_bloc.dart';
import '../bloc/clinic_doctors_event.dart';
import 'doctor_detail_back_bar.dart';
import 'doctor_detail_cards_grid.dart';
import 'doctor_detail_header_card.dart';
import 'doctor_detail_notice_banner.dart';
import 'doctor_remove_confirmation_dialog.dart';
import 'doctor_detail_stats_row.dart';
import 'edit_doctor_profile_dialog.dart';
import 'manage_doctor_schedule_dialog.dart';

class DoctorDetailView extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;
  final List<String> departments;
  final VoidCallback onBack;

  const DoctorDetailView({
    super.key,
    required this.doctor,
    required this.departments,
    required this.onBack,
  });

  void _showRemoveConfirmationDialog(BuildContext context) {
    DoctorRemoveConfirmationDialog.show(
      context,
      doctorName: doctor.name,
      onConfirm: () {
        context.read<ClinicDoctorsBloc>().add(
          DoctorDeletePressed(doctorId: doctor.id, doctorName: doctor.name),
        );
      },
    );
  }

  void _openEditProfile(BuildContext context) {
    final bloc = context.read<ClinicDoctorsBloc>();
    EditDoctorProfileDialog.show(
      context,
      doctor: doctor,
      departments: departments,
      onSave: (updated) => bloc.add(DoctorProfileUpdated(updated)),
    );
  }

  void _openManageSchedule(BuildContext context) {
    final bloc = context.read<ClinicDoctorsBloc>();
    ManageDoctorScheduleDialog.show(
      context,
      doctor: doctor,
      onSave: (schedule, slotDuration) {
        bloc.add(
          DoctorScheduleUpdated(
            doctorId: doctor.id,
            schedule: schedule,
            slotDuration: slotDuration,
          ),
        );
      },
    );
  }

  void _updateLeave(BuildContext context, List<String> leaveDates) {
    context.read<ClinicDoctorsBloc>().add(
      DoctorScheduleUpdated(
        doctorId: doctor.id,
        schedule: doctor.weeklySchedule.isNotEmpty
            ? doctor.weeklySchedule
            : DoctorDailySchedule.defaultWeekly(),
        slotDuration: doctor.slotDuration,
        leaveDates: leaveDates,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ClinicDoctorsBloc>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 992;
        final hPadding = constraints.maxWidth < 600 ? 12.0 : 20.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DoctorDetailBackBar(doctorName: doctor.name, onBack: onBack),
              const SizedBox(height: 16),
              DoctorDetailHeaderCard(
                doctor: doctor,
                onEditProfile: () => _openEditProfile(context),
                onManageSchedule: () => _openManageSchedule(context),
                onToggleAccount: () =>
                    bloc.add(DoctorAccountStatusToggled(doctor.id)),
                onRemoveDoctor: () => _showRemoveConfirmationDialog(context),
              ),
              if (doctor.accountStatus != 'active') ...[
                const SizedBox(height: 16),
                DoctorDetailNoticeBanner(doctor: doctor),
              ],
              const SizedBox(height: 16),
              DoctorDetailStatsRow(doctor: doctor),
              const SizedBox(height: 20),
              DoctorDetailCardsGrid(
                doctor: doctor,
                isWide: isWide,
                onManageSchedule: () => _openManageSchedule(context),
                onLeaveChanged: (l) => _updateLeave(context, l),
                onRemoveDoctor: () => _showRemoveConfirmationDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
