import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/repositories/platform_support_repository.dart';
import '../../domain/entities/platform_support_ticket_entity.dart';

class PlatformTicketsBroadcastDialog extends StatefulWidget {
  final List<PlatformSupportTicketEntity> allTickets;
  final PlatformSupportRepository repository;

  const PlatformTicketsBroadcastDialog({
    super.key,
    required this.allTickets,
    required this.repository,
  });

  static Future<void> show(
    BuildContext context, {
    required List<PlatformSupportTicketEntity> allTickets,
    required PlatformSupportRepository repository,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => PlatformTicketsBroadcastDialog(
        allTickets: allTickets,
        repository: repository,
      ),
    );
  }

  @override
  State<PlatformTicketsBroadcastDialog> createState() =>
      _PlatformTicketsBroadcastDialogState();
}

class _PlatformTicketsBroadcastDialogState
    extends State<PlatformTicketsBroadcastDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isBroadcasting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _handleBroadcast() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    setState(() => _isBroadcasting = true);

    final openTickets = widget.allTickets
        .where((t) => t.status != 'resolved')
        .toList();
    for (final t in openTickets) {
      try {
        await widget.repository.sendReply(
          ticketId: t.id,
          text: '📢 [BROADCAST NOTICE] $title: $body',
          senderName: 'Platform Network Operations',
          isInternalNote: false,
        );
      } catch (_) {}
    }

    if (mounted) {
      Navigator.pop(context);
      AppSnackBar.showSuccess(
        context,
        message:
            'Broadcast notice sent to ${openTickets.length} active tickets!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      title: Text(
        'Broadcast Notice to Active Queues & Tickets',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispatches an urgent platform-wide operations advisory to all clinics and open patient concern tickets.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Notice Title',
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
                hintText: 'e.g. Platform Network Latency Advisory',
                hintStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
                filled: true,
                fillColor: const Color(0xFF0B0F19),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              maxLines: 3,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Notice Content',
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
                hintText:
                    'Describe details, ETA, and instructed staff actions...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
                filled: true,
                fillColor: const Color(0xFF0B0F19),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                ),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isBroadcasting ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _isBroadcasting ? null : _handleBroadcast,
          icon: _isBroadcasting
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send_rounded, size: 14, color: Colors.white),
          label: Text(
            'Broadcast Now',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
