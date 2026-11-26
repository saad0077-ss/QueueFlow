import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/appointment_entity.dart';
import 'booking_receipt_dialog.dart';
import 'my_booking_card_actions.dart';
import 'my_booking_card_header.dart';

class MyBookingCard extends StatelessWidget {
  final AppointmentEntity apt;
  final VoidCallback onCancel;
  final VoidCallback? onTrackLiveQueue;
  final ClinicEntity? clinicOverride;
  final Map<String, dynamic>? queueDocOverride;
  final DateTime? currentTimeOverride;

  const MyBookingCard({
    super.key,
    required this.apt,
    required this.onCancel,
    this.onTrackLiveQueue,
    this.clinicOverride,
    this.queueDocOverride,
    this.currentTimeOverride,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final refText = (apt.payment?.paymentId.isNotEmpty ?? false)
        ? apt.payment!.paymentId
        : apt.bookingRef;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyBookingCardHeader(apt: apt, colors: colors),
          const SizedBox(height: 10),
          _infoRow(context, Icons.person_outline_rounded, apt.doctorName),
          const SizedBox(height: 6),
          _infoRow(context, Icons.schedule_rounded, apt.dateTime),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: apt.bookingRef));
                    AppSnackBar.showSuccess(
                      context,
                      title: 'Copied',
                      message: 'Booking reference ${apt.bookingRef} copied!',
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.bolt_rounded, size: 14, color: colors.primary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          refText,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.robotoMono(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => BookingReceiptDialog.show(context, apt),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  backgroundColor: colors.surfaceSecondary,
                  side: BorderSide(color: colors.border),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  apt.isCancelled
                      ? 'Cancellation Details ↗'
                      : 'Receipt & Details ↗',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          MyBookingCardActions(
            apt: apt,
            onCancel: onCancel,
            onTrackLiveQueue: onTrackLiveQueue,
            colors: colors,
            clinicOverride: clinicOverride,
            queueDocOverride: queueDocOverride,
            currentTimeOverride: currentTimeOverride,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 14, color: colors.textMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
          ),
        ),
      ],
    );
  }
}
