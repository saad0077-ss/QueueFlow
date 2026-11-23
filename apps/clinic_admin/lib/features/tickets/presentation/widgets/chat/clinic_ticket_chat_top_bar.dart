import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../data/repositories/clinic_support_repository.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_chat_top_bar_left.dart';
import 'clinic_ticket_chat_top_bar_right.dart';

class ClinicTicketChatTopBar extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;
  final ClinicSupportRepository repository;
  final String staffName;
  final VoidCallback? onBack;

  const ClinicTicketChatTopBar({
    super.key,
    required this.ticket,
    required this.repository,
    required this.staffName,
    this.onBack,
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
          ClinicTicketChatTopBarLeft(ticket: ticket, onBack: onBack),
          ClinicTicketChatTopBarRight(
            ticket: ticket,
            repository: repository,
            staffName: staffName,
          ),
        ],
      ),
    );
  }
}
