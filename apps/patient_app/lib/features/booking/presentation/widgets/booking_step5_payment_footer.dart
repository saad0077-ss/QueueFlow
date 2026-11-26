import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingStep5PaymentFooter extends StatelessWidget {
  final AppointmentEntity appointment;

  const BookingStep5PaymentFooter({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Status',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: colors.success.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      'PAID (RAZORPAY TEST)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: colors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Amount Paid',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${appointment.servicePrice.toStringAsFixed(2)}',
                  style: GoogleFonts.robotoMono(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (appointment.payment?.paymentId != null) ...[
          const SizedBox(height: 8),
          Text(
            'Transaction ID: ${appointment.payment!.paymentId}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.robotoMono(
              fontSize: 10.5,
              color: colors.textSubtle,
            ),
          ),
        ],
      ],
    );
  }
}
