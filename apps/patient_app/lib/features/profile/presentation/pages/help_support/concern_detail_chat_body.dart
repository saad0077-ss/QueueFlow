import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/support_ticket_entity.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../widgets/concern_chat/concern_chat_feed.dart';
import '../../widgets/concern_chat/concern_detail_rating_card.dart';
import '../../widgets/concern_chat/concern_detail_summary_card.dart';

class ConcernDetailChatBody extends StatelessWidget {
  final SupportTicketEntity ticket;
  final ScrollController scrollController;
  final VoidCallback onToggleResolve;
  final Map<String, DateTime> fallbackStartTimes;

  const ConcernDetailChatBody({
    super.key,
    required this.ticket,
    required this.scrollController,
    required this.onToggleResolve,
    required this.fallbackStartTimes,
  });

  String _formatSlaCountdown(SupportTicketEntity ticket) {
    if (ticket.status.toLowerCase() == 'resolved') return '00:00';
    final slaMins = ticket.slaMinutes > 0 ? ticket.slaMinutes : 25;
    final created = ticket.createdAtDate ??
        fallbackStartTimes.putIfAbsent(ticket.id, () => DateTime.now());
    final diff = created
        .add(Duration(minutes: slaMins))
        .difference(DateTime.now());
    if (diff.isNegative) {
      final past = diff.abs();
      return '-${past.inMinutes.toString().padLeft(2, '0')}:${past.inSeconds.remainder(60).toString().padLeft(2, '0')} (Overdue)';
    }
    return '${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}:${diff.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = ticket.status.toLowerCase() == 'resolved';
    final isInProg = ticket.status.toLowerCase() == 'in_progress' ||
        ticket.status.toLowerCase() == 'in-progress';

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConcernDetailSummaryCard(
            ticket: ticket,
            isResolved: isResolved,
            isInProg: isInProg,
            slaCountdown: _formatSlaCountdown(ticket),
          ),
          const SizedBox(height: 16),
          ConcernChatFeed(
            ticket: ticket,
            isResolved: isResolved,
            onToggleResolve: onToggleResolve,
          ),
          const SizedBox(height: 14),
          if (isResolved)
            ConcernDetailRatingCard(
              ticket: ticket,
              onRate: (star) => context.read<ProfileBloc>().add(
                    ProfileTicketRated(
                      ticketId: ticket.id,
                      rating: star,
                    ),
                  ),
            ),
        ],
      ),
    );
  }
}
