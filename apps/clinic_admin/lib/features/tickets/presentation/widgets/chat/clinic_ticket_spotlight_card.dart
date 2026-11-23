import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_spotlight_actions.dart';
import 'clinic_ticket_spotlight_avatar.dart';
import 'clinic_ticket_spotlight_details.dart';

class ClinicTicketSpotlightCard extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;
  final String initials;
  final VoidCallback? onNavigateToQueue;

  const ClinicTicketSpotlightCard({
    super.key,
    required this.ticket,
    required this.initials,
    this.onNavigateToQueue,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 950;

          final avatarWidget = ClinicTicketSpotlightAvatar(
            ticket: ticket,
            initials: initials,
          );

          final detailsWidget = ClinicTicketSpotlightDetails(ticket: ticket);

          final actionsWidget = ClinicTicketSpotlightActions(
            ticket: ticket,
            onNavigateToQueue: onNavigateToQueue,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    avatarWidget,
                    const SizedBox(width: 12),
                    Expanded(child: detailsWidget),
                  ],
                ),
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerLeft, child: actionsWidget),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              avatarWidget,
              const SizedBox(width: 12),
              Expanded(child: detailsWidget),
              const SizedBox(width: 8),
              actionsWidget,
            ],
          );
        },
      ),
    );
  }
}
