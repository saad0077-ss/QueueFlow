import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_chat_helpers.dart';

class ClinicTicketChatSourceChip extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;

  const ClinicTicketChatSourceChip({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isApp = ClinicTicketChatHelpers.isTicketAppRelated(ticket);

    final bgColor = isApp
        ? (colors.isDark
              ? const Color(0xFF0C4A6E).withValues(alpha: 0.55)
              : const Color(0xFFE0F2FE))
        : (colors.isDark
              ? const Color(0xFF1E1B4B).withValues(alpha: 0.5)
              : const Color(0xFFEEF2FF));

    final borderColor = isApp
        ? (colors.isDark
              ? const Color(0xFF0284C7).withValues(alpha: 0.45)
              : const Color(0xFFBAE6FD))
        : (colors.isDark
              ? const Color(0xFF4338CA).withValues(alpha: 0.35)
              : const Color(0xFFC7D2FE));

    final textColor = isApp
        ? (colors.isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
        : (colors.isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA));

    final label = isApp
        ? 'QueueFlow App'
        : (ticket.clinicName.isNotEmpty ? ticket.clinicName : 'Clinic');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isApp ? '📱' : '🏥', style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
