import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/support_ticket_entity.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../widgets/concern_chat/concern_chat_feed.dart';
import '../../widgets/concern_chat/concern_detail_rating_card.dart';
import '../../widgets/concern_chat/concern_detail_reply_bar.dart';
import '../../widgets/concern_chat/concern_detail_sla_box.dart';
import '../../widgets/concern_chat/concern_detail_summary_card.dart';

/// Two-column desktop/web layout placing concern details + progress on the left
/// and a full-height scrollable Care Desk chat panel on the right.
class ConcernDetailWebSplitBody extends StatelessWidget {
  final SupportTicketEntity ticket;
  final ScrollController scrollController;
  final TextEditingController replyController;
  final bool isSending;
  final VoidCallback onToggleResolve;
  final VoidCallback onSendReply;
  final Map<String, DateTime> fallbackStartTimes;

  const ConcernDetailWebSplitBody({
    super.key,
    required this.ticket,
    required this.scrollController,
    required this.replyController,
    required this.isSending,
    required this.onToggleResolve,
    required this.onSendReply,
    required this.fallbackStartTimes,
  });

  @override
  Widget build(BuildContext context) {
    final statusLower = ticket.status.toLowerCase();
    final isResolved = statusLower == 'resolved';
    final isInProg = statusLower == 'in_progress' || statusLower == 'in-progress';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1380),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
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
                      if (isResolved) ...[
                        const SizedBox(height: 14),
                        ConcernDetailRatingCard(
                          ticket: ticket,
                          onRate: (star) => context.read<ProfileBloc>().add(
                            ProfileTicketRated(ticketId: ticket.id, rating: star),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 7,
                child: ConcernChatFeed(
                  ticket: ticket,
                  isResolved: isResolved,
                  onToggleResolve: onToggleResolve,
                  scrollablePanel: true,
                  scrollController: scrollController,
                  footer: ConcernDetailReplyBar(
                    controller: replyController,
                    isSending: isSending,
                    isResolved: isResolved,
                    ticket: ticket,
                    onSend: onSendReply,
                    onReopen: onToggleResolve,
                    embedded: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
