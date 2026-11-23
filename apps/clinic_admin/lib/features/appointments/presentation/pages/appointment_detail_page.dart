import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_appointment_entity.dart';
import '../widgets/detail/appointment_detail_hero_card.dart';
import '../widgets/detail/appointment_detail_notes_card.dart';
import '../widgets/detail/appointment_detail_payment_card.dart';
import '../widgets/detail/appointment_detail_service_card.dart';
import '../widgets/detail/appointment_detail_timeline_card.dart';
import '../widgets/detail/appointment_detail_visit_card.dart';

class AppointmentDetailPage extends StatelessWidget {
  final ClinicAppointmentEntity appointment;
  final VoidCallback onBack;
  final VoidCallback onCheckIn;
  final VoidCallback onComplete;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const AppointmentDetailPage({
    super.key,
    required this.appointment,
    required this.onBack,
    required this.onCheckIn,
    required this.onComplete,
    required this.onReschedule,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;

          final mainColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppointmentDetailServiceCard(appointment: appointment),
              const SizedBox(height: 18),
              AppointmentDetailVisitCard(appointment: appointment),
              const SizedBox(height: 18),
              AppointmentDetailNotesCard(appointment: appointment),
            ],
          );

          final sideColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppointmentDetailPaymentCard(appointment: appointment),
              const SizedBox(height: 18),
              AppointmentDetailTimelineCard(appointment: appointment),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: colors.textMuted,
                  ),
                  label: Text(
                    'Back to Appointments',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              AppointmentDetailHeroCard(
                appointment: appointment,
                isWide: wide,
                onCheckIn: onCheckIn,
                onComplete: onComplete,
                onReschedule: onReschedule,
                onCancel: onCancel,
              ),
              const SizedBox(height: 18),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 60, child: mainColumn),
                    const SizedBox(width: 18),
                    Expanded(flex: 40, child: sideColumn),
                  ],
                )
              else ...[
                mainColumn,
                const SizedBox(height: 18),
                sideColumn,
              ],
            ],
          );
        },
      ),
    );
  }
}
