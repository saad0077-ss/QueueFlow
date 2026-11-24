import 'package:flutter/material.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/clinic_details/presentation/widgets/doctor_rate_dialog.dart';

class BookingHistoryDialogHelper {
  BookingHistoryDialogHelper._();

  static void openRating(BuildContext context, AppointmentEntity apt) {
    showDialog(
      context: context,
      builder: (_) => DoctorRateDialog(
        doctorName: apt.doctorName,
        onSubmit: (rating, comment) {
          Navigator.of(context).pop();
          AppSnackBar.showSuccess(
            context,
            message: 'Rating ($rating ★) submitted for ${apt.doctorName}',
          );
        },
      ),
    );
  }
}
