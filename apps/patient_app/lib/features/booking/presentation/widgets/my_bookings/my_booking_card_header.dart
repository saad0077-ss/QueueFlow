import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/appointment_entity.dart';
import 'booking_receipt_dialog_helpers.dart';

class MyBookingCardHeader extends StatelessWidget {
  final AppointmentEntity apt;
  final AppColorsExtension colors;

  const MyBookingCardHeader({
    super.key,
    required this.apt,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = colors.primary;
    String statusLabel = 'UPCOMING';
    if (apt.isCompleted) {
      statusColor = colors.success;
      statusLabel = 'COMPLETED';
    } else if (apt.isCheckedIn) {
      statusColor = colors.success;
      statusLabel = 'CHECKED IN';
    } else if (apt.isCancelled) {
      statusColor = colors.error;
      statusLabel = 'CANCELLED';
    } else if (apt.isPending) {
      statusColor = colors.warning;
      statusLabel = 'PENDING';
    }
    final price = '₹${apt.servicePrice.toStringAsFixed(0)}';
    final payColor = apt.isPaid ? colors.success : colors.warning;
    var payText = apt.isPaid ? '✓ PAID · $price' : '⏳ DUE · $price';
    var payColor2 = payColor;
    if (apt.isCancelled) {
      payText = apt.isPaid ? '↩ REFUND · $price' : 'NO REFUND · UNPAID';
      payColor2 = apt.isPaid ? colors.warning : colors.textMuted;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apt.clinicName,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    apt.serviceName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BookingReceiptDialogHelpers.pill(statusLabel, statusColor),
                const SizedBox(height: 5),
                BookingReceiptDialogHelpers.pill(payText, payColor2),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (apt.doctorSpecialty.isNotEmpty) ...[
              Flexible(
                child: BookingReceiptDialogHelpers.pill(
                  '🩺 ${apt.doctorSpecialty}',
                  colors.success,
                  size: 10.5,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              '⏰ ${apt.serviceDuration} mins',
              style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
