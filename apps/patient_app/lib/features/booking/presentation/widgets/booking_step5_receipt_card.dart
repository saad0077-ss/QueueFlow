import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'booking_step5_payment_footer.dart';

class BookingStep5ReceiptCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback onCopyReference;

  const BookingStep5ReceiptCard({
    super.key,
    required this.appointment,
    required this.onCopyReference,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rows = [
      (label: 'Clinic', value: appointment.clinicName, sub: appointment.clinicAddress, hi: false),
      (label: 'Doctor', value: appointment.doctorName, sub: appointment.doctorSpecialty, hi: false),
      (label: 'Service', value: appointment.serviceName, sub: '${appointment.serviceDuration} min consultation', hi: false),
      (label: 'Scheduled For', value: appointment.dateTime, sub: '', hi: true),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BOOKING REFERENCE',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: colors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.bookingRef,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.robotoMono(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onCopyReference,
                icon: Icon(Icons.copy_rounded, color: colors.primary),
                tooltip: 'Copy Reference',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _detailRow(
              context,
              rows[i].label,
              rows[i].value,
              subtitle: rows[i].sub,
              isHighlight: rows[i].hi,
            ),
          ],
          const SizedBox(height: 14),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 14),
          BookingStep5PaymentFooter(appointment: appointment),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
    String subtitle = '',
    bool isHighlight = false,
  }) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                textAlign: TextAlign.end,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isHighlight ? colors.primary : colors.textPrimary,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
