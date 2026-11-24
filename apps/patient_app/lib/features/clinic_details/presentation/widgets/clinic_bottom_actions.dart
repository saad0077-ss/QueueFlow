import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicBottomActions extends StatelessWidget {
  final VoidCallback onBookAppointment;

  const ClinicBottomActions({super.key, required this.onBookAppointment});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBookAppointment,
                borderRadius: BorderRadius.circular(14),
                child: Center(
                  child: Text(
                    'Book Appointment',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
