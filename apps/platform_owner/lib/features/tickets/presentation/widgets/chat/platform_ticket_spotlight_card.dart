import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_ticket_spotlight_avatar.dart';
import 'platform_ticket_spotlight_details.dart';

class PlatformTicketSpotlightCard extends StatelessWidget {
  final PlatformSupportTicketEntity ticket;
  final String initials;
  final ImageProvider? avatarProvider;

  const PlatformTicketSpotlightCard({
    super.key,
    required this.ticket,
    required this.initials,
    this.avatarProvider,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? null : colors.surfaceSecondary,
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF131D31), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2D44) : colors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PlatformTicketSpotlightAvatar(
            ticket: ticket,
            initials: initials,
            avatarProvider: avatarProvider,
          ),
          const SizedBox(width: 12),
          Expanded(child: PlatformTicketSpotlightDetails(ticket: ticket)),
        ],
      ),
    );
  }
}
