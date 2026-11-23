import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'header/clinic_tickets_header_actions.dart';

class ClinicTicketsHeader extends StatelessWidget {
  final String clinicName;
  final VoidCallback onLogTicket;
  final VoidCallback onSync;

  const ClinicTicketsHeader({
    super.key,
    required this.clinicName,
    required this.onLogTicket,
    required this.onSync,
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
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.apartment_rounded,
                      size: 13,
                      color: colors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${clinicName.toUpperCase()} • CLINIC ADMIN DESK',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (isNarrow) ...[
                titleWidget,
                const SizedBox(height: 14),
                actionsWidget,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleWidget),
                    const SizedBox(width: 16),
                    actionsWidget,
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
