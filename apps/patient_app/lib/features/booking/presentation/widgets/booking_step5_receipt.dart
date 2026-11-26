import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';
import 'package:patient_app/core/widgets/gradient_button.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'booking_step5_receipt_card.dart';

class BookingStep5Receipt extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback onViewMyBookings;
  final VoidCallback onBackToHome;

  const BookingStep5Receipt({
    super.key,
    required this.appointment,
    required this.onViewMyBookings,
    required this.onBackToHome,
  });

  void _copyReference(BuildContext context) {
    Clipboard.setData(ClipboardData(text: appointment.bookingRef));
    AppSnackBar.showSuccess(
      context,
      title: 'Copied to Clipboard',
      message: 'Booking Reference ${appointment.bookingRef} copied!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.45),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Appointment Confirmed!',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your medical consultation has been booked successfully.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
        ),
        const SizedBox(height: 20),
        BookingStep5ReceiptCard(
          appointment: appointment,
          onCopyReference: () => _copyReference(context),
        ),
        const SizedBox(height: 24),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientButton(
                  text: 'View in My Bookings',
                  onPressed: onViewMyBookings,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colors.border, width: 1.2),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: onBackToHome,
                      child: Center(
                        child: Text(
                          'Back to Home',
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
