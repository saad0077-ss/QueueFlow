import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_appointment_entity.dart';
import '../patient_avatar.dart';
import 'appointment_status_pills.dart';

class AppointmentDetailHeroCard extends StatelessWidget {
  final ClinicAppointmentEntity appointment;
  final bool isWide;
  final VoidCallback onCheckIn;
  final VoidCallback onComplete;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const AppointmentDetailHeroCard({
    super.key,
    required this.appointment,
    required this.isWide,
    required this.onCheckIn,
    required this.onComplete,
    required this.onReschedule,
    required this.onCancel,
  });

  Widget _metaItem(
    AppColorsExtension colors,
    IconData icon,
    String text, {
    bool mono = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.textMuted),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: mono
                ? GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  )
                : GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final colors = context.colors;
    final a = appointment;
    final open = !a.isCompleted && !a.isCancelled;

    ButtonStyle outlined(Color side, {Color? bg}) => OutlinedButton.styleFrom(
      backgroundColor: bg,
      side: BorderSide(color: side),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );

    TextStyle label(Color c) => GoogleFonts.inter(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      color: c,
    );

    return [
      if (open && !a.isCheckedIn)
        ElevatedButton.icon(
          onPressed: onCheckIn,
          icon: const Icon(
            Icons.how_to_reg_rounded,
            size: 17,
            color: Colors.white,
          ),
          label: Text('Check In Patient', style: label(Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      if (open)
        OutlinedButton.icon(
          onPressed: onComplete,
          icon: Icon(
            Icons.check_circle_outline_rounded,
            size: 17,
            color: colors.success,
          ),
          label: Text('Mark Completed', style: label(colors.success)),
          style: outlined(colors.success),
        ),
      if (open)
        OutlinedButton.icon(
          onPressed: onReschedule,
          icon: Icon(
            Icons.event_repeat_rounded,
            size: 17,
            color: colors.textPrimary,
          ),
          label: Text('Reschedule', style: label(colors.textPrimary)),
          style: outlined(colors.border, bg: colors.surfaceSecondary),
        ),
      if (open)
        OutlinedButton.icon(
          onPressed: onCancel,
          icon: Icon(Icons.close_rounded, size: 17, color: colors.error),
          label: Text('Cancel Appointment', style: label(colors.error)),
          style: outlined(colors.error),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = appointment;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PatientAvatar(
                photo: a.customerPhoto,
                initials: a.initials,
                size: 64,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          a.customerName,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        AppointmentStatusPill(status: a.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        _metaItem(
                          colors,
                          Icons.confirmation_number_outlined,
                          '#${a.bookingId}',
                          mono: true,
                        ),
                        _metaItem(colors, Icons.phone_outlined, a.phone),
                        _metaItem(colors, Icons.mail_outline_rounded, a.email),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: isWide ? WrapAlignment.end : WrapAlignment.start,
            children: _buildActionButtons(context),
          ),
        ],
      ),
    );
  }
}
