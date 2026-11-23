import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/support_ticket_entity.dart';

class ConcernDetailChatAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final SupportTicketEntity ticket;

  const ConcernDetailChatAppBar({super.key, required this.ticket});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: colors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Back to Raised Concerns',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '#${ticket.ticketNumber}',
                style: GoogleFonts.firaCode(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
