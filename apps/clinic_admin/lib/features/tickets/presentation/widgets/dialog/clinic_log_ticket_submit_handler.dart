import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/repositories/clinic_support_repository.dart';

class ClinicLogTicketSubmitHandler {
  static Future<bool> submit({
    required BuildContext context,
    required ClinicSupportRepository repository,
    required String clinicId,
    required String clinicName,
    required String patientName,
    required String patientPhone,
    String? patientEmail,
    String? tokenNumber,
    required String category,
    required String priority,
    required String subject,
    required String description,
    required VoidCallback onTicketLogged,
  }) async {
    try {
      await repository.createManualTicket(
        clinicId: clinicId,
        clinicName: clinicName,
        patientName: patientName,
        patientPhone: patientPhone,
        patientEmail: patientEmail,
        tokenNumber: tokenNumber,
        category: category,
        priority: priority,
        subject: subject,
        description: description,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        onTicketLogged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Patient ticket logged successfully!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log ticket: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
      return false;
    }
  }
}
