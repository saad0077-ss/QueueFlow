import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../data/models/clinic_support_ticket_model.dart';
import '../../data/repositories/clinic_support_repository.dart';
import 'chat/clinic_ticket_chat_console.dart';

class ClinicTicketChatView extends StatefulWidget {
  final ClinicSupportTicketEntity initialTicket;
  final ClinicSupportRepository repository;
  final String staffName;
  final VoidCallback onNavigateToQueue;
  final VoidCallback? onBack;

  const ClinicTicketChatView({
    super.key,
    required this.initialTicket,
    required this.repository,
    required this.staffName,
    required this.onNavigateToQueue,
    this.onBack,
  });

  @override
  State<ClinicTicketChatView> createState() => _ClinicTicketChatViewState();
}

class _ClinicTicketChatViewState extends State<ClinicTicketChatView> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isInternalNote = false;
  bool _isSending = false;

  @override
  void dispose() {
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

  Future<void> _sendMessage() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await widget.repository.sendReply(
        ticketId: widget.initialTicket.id,
        text: text,
        staffName: widget.staffName,
        isInternalNote: _isInternalNote,
      );
      _replyController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _buildConsole(ClinicSupportTicketEntity ticket) {
    return ClinicTicketChatConsole(
      ticket: ticket,
      repository: widget.repository,
      staffName: widget.staffName,
      onNavigateToQueue: widget.onNavigateToQueue,
      onBack: widget.onBack,
      scrollController: _scrollController,
      replyController: _replyController,
      isInternalNote: _isInternalNote,
      onToggleMode: (val) => setState(() => _isInternalNote = val),
      onSelectMacro: (txt) => setState(() {
        _replyController.text = txt;
        _isInternalNote = false;
      }),
      onSend: _sendMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFirebase = Firebase.apps.isNotEmpty;
    final Stream<DocumentSnapshot<Map<String, dynamic>>>? stream = hasFirebase
        ? FirebaseFirestore.instance
              .collection('support_tickets')
              .doc(widget.initialTicket.id)
              .snapshots()
        : null;

    if (stream != null) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          ClinicSupportTicketEntity ticket = widget.initialTicket;
          if (snapshot.hasData && snapshot.data!.exists) {
            try {
              ticket = ClinicSupportTicketModel.fromFirestore(snapshot.data!);
            } catch (_) {
              ticket = widget.initialTicket;
            }
          }
          return _buildConsole(ticket);
        },
      );
    }
    return _buildConsole(widget.initialTicket);
  }
}
