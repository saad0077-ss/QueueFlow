import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'header/clinic_tickets_header_actions.dart';

class ClinicTicketsHeader extends StatelessWidget {
  final String clinicName;
  final VoidCallback onLogTicket;
  final VoidCallback? onSync;
  final VoidCallback? onExportPdf;

  const ClinicTicketsHeader({
    super.key,
    required this.clinicName,
    required this.onLogTicket,
    this.onSync,
    this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 750;

          final titleWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinic Patient Care & Support Desk',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Resolve patient queue inquiries, delay notifications, doctor triage & appointments for $clinicName',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: colors.textMuted,
                ),
              ),
            ],
          );

          final actionsWidget = ClinicTicketsHeaderActions(
            onLogTicket: onLogTicket,
            onSync: onSync,
            onExportPdf: onExportPdf,
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget,
                const SizedBox(height: 14),
                actionsWidget,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: titleWidget),
              const SizedBox(width: 16),
              actionsWidget,
            ],
          );
        },
      ),
    );
  }
}
