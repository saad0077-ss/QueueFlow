import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../data/models/support_ticket_model.dart';
import '../../../domain/entities/support_ticket_entity.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../bloc/profile_state.dart';
import '../../widgets/concern_chat/concern_chat_feed.dart';
import '../../widgets/concern_chat/concern_detail_rating_card.dart';
import '../../widgets/concern_chat/concern_detail_reply_bar.dart';
import '../../widgets/concern_chat/concern_detail_summary_card.dart';
import 'concern_detail_chat_app_bar.dart';

class ConcernDetailChatScreen extends StatefulWidget {
  final String ticketId;
  const ConcernDetailChatScreen({super.key, required this.ticketId});

  @override
  State<ConcernDetailChatScreen> createState() =>
      _ConcernDetailChatScreenState();
}

class _ConcernDetailChatScreenState extends State<ConcernDetailChatScreen> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  Timer? _slaTimer;
  final Map<String, DateTime> _fallbackStartTimes = {};

  @override
  void initState() {
    super.initState();
    _slaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _slaTimer?.cancel();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    context.read<ProfileBloc>().add(
      ProfileTicketReplySent(ticketId: widget.ticketId, text: text),
    );
    _replyController.clear();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    });
  }

  void _toggleResolve(SupportTicketEntity ticket) {
    final isResolved = ticket.status.toLowerCase() == 'resolved';
    context.read<ProfileBloc>().add(
      ProfileTicketStatusUpdated(
        ticketId: ticket.id,
        status: isResolved ? 'in_progress' : 'resolved',
      ),
    );
  }

  String _formatSlaCountdown(SupportTicketEntity ticket) {
    if (ticket.status.toLowerCase() == 'resolved') return '00:00';
    final slaMins = ticket.slaMinutes > 0 ? ticket.slaMinutes : 25;
    final created =
        ticket.createdAtDate ??
        _fallbackStartTimes.putIfAbsent(ticket.id, () => DateTime.now());
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
    final colors = context.colors;
    final hasFirebase = Firebase.apps.isNotEmpty;
    final Stream<DocumentSnapshot<Map<String, dynamic>>>? stream = hasFirebase
        ? FirebaseFirestore.instance
              .collection('support_tickets')
              .doc(widget.ticketId)
              .snapshots()
        : null;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) => _scrollToBottom(),
      builder: (context, state) {
        SupportTicketEntity? foundTicket;
        for (final t in state.supportTickets) {
          if (t.id == widget.ticketId) {
            foundTicket = t;
            break;
          }
        }
        final stateTicket =
            foundTicket ??
            SupportTicketEntity(
              id: widget.ticketId,
              clinicId: '',
              clinicName: 'Support',
              category: 'queue',
              subject: 'Support Concern',
              description: '',
              status: 'open',
              priority: 'medium',
              createdAt: 'Today',
              slaNotice: '< 15m SLA',
              messages: const [],
            );

        if (stream != null) {
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              var activeTicket = stateTicket;
              if (snapshot.hasData && snapshot.data!.exists) {
                try {
                  activeTicket = SupportTicketModel.fromFirestore(
                    snapshot.data!,
                  );
                } catch (_) {}
              }
              return _buildScaffold(colors, activeTicket);
            },
          );
        }
        return _buildScaffold(colors, stateTicket);
      },
    );
  }

  Widget _buildScaffold(AppColorsExtension colors, SupportTicketEntity ticket) {
    final isResolved = ticket.status.toLowerCase() == 'resolved';
    final isInProg =
        ticket.status.toLowerCase() == 'in_progress' ||
        ticket.status.toLowerCase() == 'in-progress';

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: ConcernDetailChatAppBar(ticket: ticket),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
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
                    onToggleResolve: () => _toggleResolve(ticket),
                  ),
                  const SizedBox(height: 14),
                  if (isResolved)
                    ConcernDetailRatingCard(
                      ticket: ticket,
                      onRate: (star) => context.read<ProfileBloc>().add(
                        ProfileTicketRated(
                          ticketId: widget.ticketId,
                          rating: star,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          ConcernDetailReplyBar(
            controller: _replyController,
            isSending: _isSending,
            isResolved: isResolved,
            ticket: ticket,
            onSend: _sendReply,
            onReopen: () => _toggleResolve(ticket),
          ),
        ],
      ),
    );
  }
}
