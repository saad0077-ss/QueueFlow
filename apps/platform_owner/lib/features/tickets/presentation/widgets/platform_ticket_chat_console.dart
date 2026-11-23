import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../data/models/platform_support_ticket_model.dart';
import '../../domain/entities/platform_support_ticket_entity.dart';
import '../../domain/repositories/platform_support_repository.dart';
import 'chat/platform_ticket_chat_top_bar.dart';
import 'chat/platform_ticket_conversation_feed.dart';
import 'chat/platform_ticket_delete_dialog.dart';
import 'chat/platform_ticket_macros_bar.dart';
import 'chat/platform_ticket_reply_input.dart';
import 'chat/platform_ticket_spotlight_card.dart';

class PlatformTicketChatConsole extends StatefulWidget {
  final PlatformSupportTicketEntity initialTicket;
  final PlatformSupportRepository repository;
  final String adminName;
  final VoidCallback onTicketDeleted;
  final VoidCallback? onBack;

  const PlatformTicketChatConsole({
    super.key,
    required this.initialTicket,
    required this.repository,
    this.adminName = 'Platform Admin',
    required this.onTicketDeleted,
    this.onBack,
  });

  @override
  State<PlatformTicketChatConsole> createState() =>
      _PlatformTicketChatConsoleState();
}

class _PlatformTicketChatConsoleState extends State<PlatformTicketChatConsole> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isInternalNote = false;
  bool _isSending = false;
  Timer? _countdownTicker;

  @override
  void initState() {
    super.initState();
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendReply(PlatformSupportTicketEntity ticket) async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      await widget.repository.sendReply(
        ticketId: ticket.id,
        senderName: widget.adminName,
        text: text,
        isInternalNote: _isInternalNote,
      );
      _replyController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {}
    if (mounted) setState(() => _isSending = false);
  }

  void _deleteTicket(BuildContext ctx, PlatformSupportTicketEntity ticket) {
    PlatformTicketDeleteDialog.show(
      ctx,
      ticketNumber: ticket.ticketNumber,
      onConfirm: () async {
        await widget.repository.deleteTicket(ticketId: ticket.id);
        widget.onTicketDeleted();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot>? stream;
    try {
      if (Firebase.apps.isNotEmpty) {
        stream = FirebaseFirestore.instance
            .collection('support_tickets')
            .doc(widget.initialTicket.id)
            .snapshots();
      }
    } catch (_) {}

    if (stream == null) return _buildBody(widget.initialTicket);

    return StreamBuilder<DocumentSnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        var current = widget.initialTicket;
        if (snapshot.hasData && snapshot.data!.exists) {
          try {
            current = PlatformSupportTicketModel.fromFirestore(snapshot.data!);
          } catch (_) {}
        }
        return _buildBody(current);
      },
    );
  }

  Widget _buildBody(PlatformSupportTicketEntity ticket) {
    final colors = context.colors;
    final isResolved = ticket.status.toLowerCase() == 'resolved';
    final initials = ticket.patientName.isNotEmpty
        ? ticket.patientName
              .split(' ')
              .map((p) => p.isNotEmpty ? p[0] : '')
              .take(2)
              .join('')
              .toUpperCase()
        : 'PT';

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlatformTicketChatTopBar(
            ticket: ticket,
            repository: widget.repository,
            onBack: widget.onBack,
            onDelete: () => _deleteTicket(context, ticket),
          ),
          PlatformTicketSpotlightCard(ticket: ticket, initials: initials),
          Expanded(
            child: Container(
              color: colors.isDark
                  ? const Color(0xFF0B0F19)
                  : colors.surfaceSecondary,
              child: PlatformTicketConversationFeed(
                ticket: ticket,
                scrollController: _scrollController,
              ),
            ),
          ),
          if (!isResolved)
            PlatformTicketMacrosBar(
              onSelectMacro: (m) => setState(() {
                _replyController.text = m;
                _isInternalNote = false;
              }),
            ),
          if (!isResolved)
            PlatformTicketReplyInput(
              controller: _replyController,
              isInternalNote: _isInternalNote,
              isSending: _isSending,
              onToggleMode: (val) => setState(() => _isInternalNote = val),
              onSend: () => _sendReply(ticket),
            ),
        ],
      ),
    );
  }
}
