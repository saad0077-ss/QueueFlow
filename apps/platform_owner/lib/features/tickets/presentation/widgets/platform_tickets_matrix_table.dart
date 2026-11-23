import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_support_ticket_entity.dart';
import 'matrix/platform_tickets_matrix_columns.dart';
import 'matrix/platform_tickets_matrix_row_builder.dart';

class PlatformTicketsMatrixTable extends StatelessWidget {
  final List<PlatformSupportTicketEntity> tickets;
  final ValueChanged<PlatformSupportTicketEntity> onSelectTicket;
  final ValueChanged<PlatformSupportTicketEntity> onResolveTicket;

  const PlatformTicketsMatrixTable({
    super.key,
    required this.tickets,
    required this.onSelectTicket,
    required this.onResolveTicket,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (tickets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              'No tickets found in matrix',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search query, clinic selection or status filter.',
              style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            horizontalMargin: 20,
            columnSpacing: 24,
            headingRowHeight: 44,
            dataRowMinHeight: 56,
            dataRowMaxHeight: 64,
            headingRowColor: WidgetStateProperty.all(
              colors.surfaceSecondary.withValues(alpha: 0.6),
            ),
            columns: PlatformTicketsMatrixColumns.getColumns(),
            rows: tickets
                .map(
                  (t) => PlatformTicketsMatrixRowBuilder.buildRow(
                    ticket: t,
                    colors: colors,
                    onSelectTicket: onSelectTicket,
                    onResolveTicket: onResolveTicket,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
