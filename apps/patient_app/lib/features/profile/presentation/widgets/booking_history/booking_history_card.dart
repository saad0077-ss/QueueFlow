import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'booking_history_card_actions.dart';
import 'booking_history_card_header.dart';
import 'booking_slip_sheet.dart';

class BookingHistoryCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback? onBookAgain;
  final VoidCallback? onRateVisit;
  final VoidCallback? onTrackQueue;

  const BookingHistoryCard({
    super.key,
    required this.appointment,
    this.onBookAgain,
    this.onRateVisit,
    this.onTrackQueue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingHistoryCardHeader(appointment: appointment),
          const SizedBox(height: 10),
          _buildDoctorAndDate(colors),
          const SizedBox(height: 10),
          _buildBookingRef(context, colors),
          const SizedBox(height: 10),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 8),
          BookingHistoryCardActions(
            isUpcoming: appointment.isUpcoming,
            onTrackQueue: onTrackQueue,
            onRateVisit: onRateVisit,
            onBookAgain: onBookAgain,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorAndDate(dynamic colors) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.person_rounded, size: 14, color: colors.textMuted),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                appointment.doctorName,
                style: TextStyle(fontSize: 12, color: colors.textMuted, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.schedule_rounded, size: 14, color: colors.textMuted),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                appointment.dateTime,
                style: TextStyle(fontSize: 12, color: colors.textMuted, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingRef(BuildContext context, dynamic colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: colors.surfaceSecondary, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ID: ${appointment.bookingRef}',
            style: GoogleFonts.robotoMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0284C7),
            ),
          ),
          InkWell(
            onTap: () => BookingSlipSheet.show(context, appointment: appointment),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Receipt & Slip ↗',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
