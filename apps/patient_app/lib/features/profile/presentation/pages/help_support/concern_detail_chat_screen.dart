import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/support_ticket_model.dart';
import '../../../domain/entities/support_ticket_entity.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../bloc/profile_state.dart';
import '../../widgets/profile_tab/profile_fallback_provider.dart';
import 'concern_detail_chat_scaffold.dart';

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

  SupportTicketModel _fallbackTicket() => SupportTicketModel(
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

  Widget _buildScaffold(SupportTicketEntity ticket) {
    return ConcernDetailChatScaffold(
      ticket: ticket,
      scrollController: _scrollController,
      replyController: _replyController,
      isSending: _isSending,
      onToggleResolve: () => _toggleResolve(ticket),
      onSendReply: _sendReply,
      fallbackStartTimes: _fallbackStartTimes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileFallbackProvider(
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) => _scrollToBottom(),
        builder: (context, state) {
          final stream = Firebase.apps.isNotEmpty
              ? FirebaseFirestore.instance
                  .collection('support_tickets')
                  .doc(widget.ticketId)
                  .snapshots()
              : null;
          final stateTicket = state.supportTickets
                  .where((t) => t.id == widget.ticketId)
                  .firstOrNull ??
              _fallbackTicket();
          if (stream != null) {
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                var active = stateTicket;
                if (snapshot.hasData && snapshot.data!.exists) {
                  try {
                    active = SupportTicketModel.fromFirestore(snapshot.data!);
                  } catch (_) {}
                }
                return _buildScaffold(active);
              },
            );
          }
          return _buildScaffold(stateTicket);
        },
      ),
    );
  }
}
