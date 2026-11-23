import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';
import '../../../domain/repositories/platform_support_repository.dart';
import 'platform_ticket_chat_helpers.dart';
import 'platform_ticket_chat_number_chip.dart';

class PlatformTicketChatTopBarLeft extends StatelessWidget {
  final PlatformSupportTicketEntity ticket;
  final PlatformSupportRepository repository;
  final VoidCallback? onBack;

  const PlatformTicketChatTopBarLeft({
    super.key,
    required this.ticket,
    required this.repository,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;
    final isAppRelated = PlatformTicketChatHelpers.isTicketAppRelated(ticket);

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
                color: isDark
                    ? const Color(0xFF1E293B)
                    : colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : colors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 13,
                    color: isDark
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Back',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
        PlatformTicketChatNumberChip(ticketNumber: ticket.ticketNumber),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                PlatformTicketChatHelpers.getCategoryIcon(ticket.category),
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 4),
              Text(
                ticket.category.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFCBD5E1) : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isAppRelated
                ? (isDark
                      ? const Color(0xFF0C4A6E).withValues(alpha: 0.55)
                      : const Color(0xFFE0F2FE))
                : (isDark
                      ? const Color(0xFF1E1B4B).withValues(alpha: 0.5)
                      : const Color(0xFFEEF2FF)),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isAppRelated
                  ? (isDark
                        ? const Color(0xFF0284C7).withValues(alpha: 0.45)
                        : const Color(0xFFBAE6FD))
                  : (isDark
                        ? const Color(0xFF4338CA).withValues(alpha: 0.35)
                        : const Color(0xFFC7D2FE)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isAppRelated ? '📱' : '🏥',
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 4),
              Text(
                isAppRelated
                    ? 'QueueFlow App'
                    : (ticket.clinicName.isNotEmpty
                          ? ticket.clinicName
                          : 'Clinic'),
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isAppRelated
                      ? (isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7))
                      : (isDark
                            ? const Color(0xFFA5B4FC)
                            : const Color(0xFF4338CA)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
