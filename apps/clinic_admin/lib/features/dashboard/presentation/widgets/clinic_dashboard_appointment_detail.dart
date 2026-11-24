import 'package:flutter/material.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../../appointments/presentation/pages/appointment_detail_page.dart';
import '../../../appointments/presentation/widgets/reschedule_appointment_dialog.dart';

class ClinicDashboardAppointmentDetail extends StatelessWidget {
  final ClinicAppointmentEntity appointment;
  final VoidCallback onBack;
  final ValueChanged<ClinicAppointmentEntity> onUpdated;

  const ClinicDashboardAppointmentDetail({
    super.key,
    required this.appointment,
    required this.onBack,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return AppointmentDetailPage(
      appointment: appointment,
      onBack: onBack,
      onCheckIn: () {
        onUpdated(appointment.copyWith(status: 'checkedin'));
        AppSnackBar.showSuccess(
          context,
          message: 'Patient #${appointment.bookingId} checked in.',
        );
      },
      onComplete: () {
        onUpdated(appointment.copyWith(status: 'completed'));
        AppSnackBar.showSuccess(
          context,
          message: 'Appointment #${appointment.bookingId} completed.',
        );
      },
      onReschedule: () {
        RescheduleAppointmentDialog.show(
          context,
          appointment: appointment,
          onReschedule: (newDate, newTime) {
            onUpdated(
              appointment.copyWith(
                dateRaw: newDate,
                timeRaw: newTime,
                dateTime: '$newDate · $newTime',
                status: 'confirmed',
              ),
            );
            AppSnackBar.showSuccess(
              context,
              message: 'Appointment rescheduled to $newDate · $newTime',
            );
          },
        );
      },
      onCancel: () {
        onUpdated(
          appointment.copyWith(
            status: 'cancelled',
            payment: appointment.payment.copyWith(
              status: 'refunded',
              refundAmount: appointment.payment.amount,
              refundedAt: 'Processed to source account',
            ),
          ),
        );
        AppSnackBar.showSuccess(
          context,
          message:
              'Appointment #${appointment.bookingId} cancelled and refund processed.',
        );
      },
    );
  }
}
