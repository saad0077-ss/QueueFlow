import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';
import 'package:patient_app/features/profile/presentation/widgets/booking_history/booking_queue_availability_builder.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/appointment_entity.dart';
import 'my_bookings_actions_helper.dart';

class MyBookingCardActions extends StatelessWidget {
  final AppointmentEntity apt;
  final VoidCallback onCancel;
  final VoidCallback? onTrackLiveQueue;
  final AppColorsExtension colors;
  final ClinicEntity? clinicOverride;
  final Map<String, dynamic>? queueDocOverride;
  final DateTime? currentTimeOverride;

  const MyBookingCardActions({
    super.key,
    required this.apt,
    required this.onCancel,
    this.onTrackLiveQueue,
    required this.colors,
    this.clinicOverride,
    this.queueDocOverride,
    this.currentTimeOverride,
  });

  @override
  Widget build(BuildContext context) {
    if (apt.isCompleted) {
      return Column(
        children: [
          const SizedBox(height: 10),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              _btn('Rate Experience', Icons.star_rounded, colors.ratingGold,
                  () => MyBookingsActionsHelper.rateDoctor(context, apt)),
              const SizedBox(width: 12),
              _btn('Book Again', Icons.event_repeat_rounded, colors.textPrimary,
                  () => MyBookingsActionsHelper.bookAgain(context, apt)),
            ],
          ),
        ],
      );
    }

    if (apt.isUpcoming) {
      return BookingQueueAvailabilityBuilder(
        appointment: apt,
        overrideClinic: clinicOverride,
        overrideQueueDoc: queueDocOverride,
        currentTime: currentTimeOverride,
        builder: (_, access) {
          final showRadar = access.isEnabled;
          if (!showRadar && apt.isCheckedIn) return const SizedBox.shrink();
          return Column(
            children: [
              const SizedBox(height: 10),
              Divider(color: colors.border, height: 1),
              const SizedBox(height: 10),
              if (showRadar) _liveQueueRadarButton(context),
              if (!apt.isCheckedIn)
                Row(
                  children: [
                    _btn(
                      'Reschedule',
                      Icons.event_repeat_rounded,
                      colors.primary,
                      () => AppSnackBar.showInfo(
                        context,
                        title: 'Coming Soon',
                        message: 'Appointment rescheduling will be available soon.',
                      ),
                    ),
                    const SizedBox(width: 12),
                    _btn('Cancel', Icons.close_rounded, colors.error, onCancel),
                  ],
                ),
            ],
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _liveQueueRadarButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: apt.isCheckedIn ? 0 : 10),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () =>
            MyBookingsActionsHelper.openLiveQueueRadar(context, onTrackLiveQueue),
        icon: const Icon(Icons.radar_rounded, size: 18, color: Colors.white),
        label: Text(
          apt.isCheckedIn ? 'Live Queue Radar · Token Active' : 'Live Queue Radar',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _btn(String text, IconData icon, Color c, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14, color: c),
        label: Text(
          text,
          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: c),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.border),
          backgroundColor: colors.surfaceSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
