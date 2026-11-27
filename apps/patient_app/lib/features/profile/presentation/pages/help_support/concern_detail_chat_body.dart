import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/support_ticket_entity.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../widgets/concern_chat/concern_chat_feed.dart';
import '../../widgets/concern_chat/concern_detail_rating_card.dart';
import '../../widgets/concern_chat/concern_detail_sla_box.dart';
import '../../widgets/concern_chat/concern_detail_summary_card.dart';

/// Vertical single-column layout used on compact mobile screens (< 900px).
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

  @override
  Widget build(BuildContext context) {
    final isResolved = ticket.status.toLowerCase() == 'resolved';
    final statusLower = ticket.status.toLowerCase();
    final isInProg = statusLower == 'in_progress' || statusLower == 'in-progress';

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
            slaCountdown: ConcernDetailSlaBox.formatCountdown(
              ticket,
              fallbackStartTimes,
            ),
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
                ProfileTicketRated(ticketId: ticket.id, rating: star),
              ),
            ),
        ],
      ),
    );
  }
}
