import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../bloc/clinic_doctors_bloc.dart';
import '../bloc/clinic_doctors_event.dart';
import '../bloc/clinic_doctors_state.dart';
import 'add_doctor_dialog.dart';

class ClinicDoctorsDialogHelper {
  static void openAddDoctorModal(
    BuildContext context,
    ClinicDoctorsState state,
  ) {
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

  static void confirmDeleteDoctor(
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
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
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
}
