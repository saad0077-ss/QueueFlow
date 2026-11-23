import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/active_ticket_entity.dart';
import 'queue/banner/home_active_queue_banner_body.dart';
import 'queue/banner/home_active_queue_banner_header.dart';

/// Active Live Queue Banner matching the prototype exact layout & styling.
class HomeActiveQueueBanner extends StatelessWidget {
  final ActiveTicketEntity ticket;
  final VoidCallback onTap;

  const HomeActiveQueueBanner({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDarkMode ? 0.18 : 0.06,
            ),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeActiveQueueBannerHeader(clinicName: ticket.clinicName),
              HomeActiveQueueBannerBody(ticket: ticket),
            ],
          ),
        ),
      ),
    );
  }
}
