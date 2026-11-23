import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';

class ClinicTicketSpotlightActions extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;
  final VoidCallback? onNavigateToQueue;

  const ClinicTicketSpotlightActions({
    super.key,
    required this.ticket,
    this.onNavigateToQueue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Calling Token ${ticket.linkedTokenNumber ?? "patient"} to counter!',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            side: BorderSide(
              color: isDark ? const Color(0xFF2563EB) : const Color(0xFF3B82F6),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color(
              0xFF2563EB,
            ).withValues(alpha: isDark ? 0.1 : 0.08),
          ),
          icon: Icon(
            Icons.campaign_rounded,
            size: 14,
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
          ),
          label: Text(
            'Call Counter',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onNavigateToQueue,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            side: BorderSide(color: colors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: isDark ? const Color(0xFF1E293B) : colors.surface,
          ),
          icon: Icon(Icons.list_alt_rounded, size: 14, color: colors.textMuted),
          label: Text(
            'View Queue',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
