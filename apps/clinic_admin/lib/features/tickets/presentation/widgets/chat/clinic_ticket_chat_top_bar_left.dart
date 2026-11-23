import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_chat_helpers.dart';
import 'clinic_ticket_chat_number_chip.dart';
import 'clinic_ticket_chat_source_chip.dart';

class ClinicTicketChatTopBarLeft extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;
  final VoidCallback? onBack;

  const ClinicTicketChatTopBarLeft({
    super.key,
    required this.ticket,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (onBack != null)
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: colors.isDark
                    ? const Color(0xFF1E293B)
                    : colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: colors.isDark
                      ? const Color(0xFF334155)
                      : colors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 13,
                    color: colors.isDark
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Back',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ClinicTicketChatNumberChip(ticketNumber: ticket.ticketNumber),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors.isDark
                ? const Color(0xFF1E293B)
                : colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: colors.isDark ? const Color(0xFF334155) : colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ClinicTicketChatHelpers.getCategoryIcon(ticket.category),
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 4),
              Text(
                ticket.category.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: colors.isDark
                      ? const Color(0xFFCBD5E1)
                      : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ClinicTicketChatSourceChip(ticket: ticket),
      ],
    );
  }
}
