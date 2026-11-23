import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_appointment_entity.dart';
import '../bloc/clinic_appointments_bloc.dart';
import '../bloc/clinic_appointments_event.dart';

class AppointmentCancelConfirmationDialog {
  static void show(
    BuildContext context, {
    required ClinicAppointmentsBloc bloc,
    required ClinicAppointmentEntity appt,
  }) {
    final reasonController = TextEditingController();
    final amountController = TextEditingController(
      text: appt.payment.amount.toStringAsFixed(2),
    );
    final colors = context.colors;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.border),
        ),
        title: Text(
          'Cancel Appointment',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel the appointment for ${appt.customerName} (${appt.dateTime})?',
                style: TextStyle(color: colors.textMuted, fontSize: 13.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Cancellation Reason',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                maxLines: 2,
                style: TextStyle(color: colors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      'e.g., Doctor unavailable, emergency reschedule requested',
                  hintStyle: TextStyle(color: colors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: colors.surfaceSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Refund Amount (₹)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(color: colors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  filled: true,
                  fillColor: colors.surfaceSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Keep Appointment',
              style: TextStyle(color: colors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              final refundAmount =
                  double.tryParse(amountController.text.trim()) ?? 0.0;
              Navigator.of(ctx).pop();
              bloc.add(
                CancelAppointment(
                  appt.id,
                  reason: reason.isNotEmpty
                      ? reason
                      : 'Cancelled by clinic administration',
                  refundAmount: refundAmount,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );
  }
}
