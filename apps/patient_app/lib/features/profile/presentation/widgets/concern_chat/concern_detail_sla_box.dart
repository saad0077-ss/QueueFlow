import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/support_ticket_entity.dart';

/// Displays SLA commitment / remaining countdown banner for a support concern.
class ConcernDetailSlaBox extends StatelessWidget {
  final bool isResolved;
  final String slaCountdown;

  const ConcernDetailSlaBox({
    super.key,
    required this.isResolved,
    required this.slaCountdown,
  });

  /// Formats remaining or overdue SLA time for [ticket].
  static String formatCountdown(
    SupportTicketEntity ticket,
    Map<String, DateTime> fallbackStartTimes,
  ) {
    if (ticket.status.toLowerCase() == 'resolved') return '00:00';
    final slaMins = ticket.slaMinutes > 0 ? ticket.slaMinutes : 25;
    final created = ticket.createdAtDate ??
        fallbackStartTimes.putIfAbsent(ticket.id, () => DateTime.now());
    final diff = created.add(Duration(minutes: slaMins)).difference(DateTime.now());
    if (diff.isNegative) {
      final past = diff.abs();
      return '-${past.inMinutes.toString().padLeft(2, '0')}:'
          '${past.inSeconds.remainder(60).toString().padLeft(2, '0')} (Overdue)';
    }
    return '${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${diff.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = slaCountdown.startsWith('-');
    final accent = isResolved
        ? const Color(0xFF10B981)
        : (isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));
    final textAccent = isResolved
        ? const Color(0xFF10B981)
        : (isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          if (!isResolved)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            )
          else ...[
            Icon(Icons.check_circle_outline, size: 14, color: accent),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              isResolved
                  ? 'Resolved within SLA commitment'
                  : 'Care Desk SLA: $slaCountdown remaining',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textAccent,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isResolved ? '100% ON-TIME' : (isOverdue ? 'OVERDUE' : 'IN PROGRESS'),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textAccent,
            ),
          ),
        ],
      ),
    );
  }
}
