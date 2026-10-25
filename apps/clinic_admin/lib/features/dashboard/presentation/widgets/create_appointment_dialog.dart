import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return AlertDialog(
      backgroundColor: const Color(0xFF10192D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      title: Text(
        'Create Appointment',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Quickly schedule a new consultation or appointment for a patient.',
        style: GoogleFonts.inter(
          color: const Color(0xFF94A3B8),
          fontSize: 13,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
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
