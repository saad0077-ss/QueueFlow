import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_snack_bar.dart';

/// Modal dialog allowing clinic staff to create a new appointment.
class CreateAppointmentDialog extends StatelessWidget {
  const CreateAppointmentDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const CreateAppointmentDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      backgroundColor: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      title: Text(
        'Create Appointment',
        style: GoogleFonts.inter(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Quickly schedule a new consultation or appointment for a patient.',
        style: GoogleFonts.inter(
          color: colors.textMuted,
          fontSize: 13,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: colors.textMuted),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
            AppSnackBar.showSuccess(
              context,
              message: 'Appointment scheduled successfully.',
            );
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}
