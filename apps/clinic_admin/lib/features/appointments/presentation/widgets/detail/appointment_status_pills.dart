import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_appointment_entity.dart';

class AppointmentStatusPill extends StatelessWidget {
  final String status;

  const AppointmentStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Color bg;
    Color fg;
    String label;
    switch (status.toLowerCase()) {
      case 'confirmed':
        bg = colors.primaryTint;
        fg = colors.primary;
        label = 'CONFIRMED';
        break;
      case 'upcoming':
        bg = colors.infoTint;
        fg = colors.info;
        label = 'UPCOMING';
        break;
      case 'checkedin':
      case 'checked-in':
        bg = colors.badgeOpenBg;
        fg = colors.badgeOpenText;
        label = 'CHECKED IN';
        break;
      case 'completed':
        bg = colors.surfaceSecondary;
        fg = colors.textMuted;
        label = 'COMPLETED';
        break;
      case 'cancelled':
        bg = colors.errorTint;
        fg = colors.error;
        label = 'CANCELLED';
        break;
      default:
        bg = colors.surfaceSecondary;
        fg = colors.textMuted;
        label = status.toUpperCase();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: fg,
        ),
      ),
    );
  }
}

class AppointmentPaymentPill extends StatelessWidget {
  final AppointmentPaymentEntity payment;

  const AppointmentPaymentPill({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Color bg;
    final Color fg;
    final String label;
    if (payment.isPaid) {
      bg = colors.successTint;
      fg = colors.success;
      label = 'PAID';
    } else if (payment.isRefunded) {
      bg = colors.errorTint;
      fg = colors.error;
      label = payment.isRefundPending ? 'REFUND PENDING' : 'REFUNDED';
    } else if (payment.isVoid) {
      bg = colors.surfaceSecondary;
      fg = colors.textMuted;
      label = 'VOID';
    } else {
      bg = colors.warningTint;
      fg = colors.warning;
      label = 'DUE';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
