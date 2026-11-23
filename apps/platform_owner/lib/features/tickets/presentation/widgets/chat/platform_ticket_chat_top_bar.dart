import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';
import '../../../domain/repositories/platform_support_repository.dart';
import 'platform_ticket_chat_top_bar_left.dart';
import 'platform_ticket_chat_top_bar_right.dart';

class PlatformTicketChatTopBar extends StatelessWidget {
  final PlatformSupportTicketEntity ticket;
  final PlatformSupportRepository repository;
  final VoidCallback? onBack;
  final VoidCallback onDelete;

  const PlatformTicketChatTopBar({
    super.key,
    required this.ticket,
    required this.repository,
    this.onBack,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          PlatformTicketChatTopBarLeft(
            ticket: ticket,
            repository: repository,
            onBack: onBack,
          ),
          PlatformTicketChatTopBarRight(
            ticket: ticket,
            repository: repository,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}
