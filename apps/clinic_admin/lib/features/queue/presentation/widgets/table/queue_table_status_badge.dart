import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QueueTableStatusBadge extends StatelessWidget {
  final String status;
  const QueueTableStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();

    Color bg;
    Color fg;
    String label = status.toUpperCase();

    switch (s) {
      case 'called':
        bg = const Color(0xFF10B981).withValues(alpha: 0.14);
        fg = const Color(0xFF059669);
        break;
      case 'waiting':
        bg = const Color(0xFF0284C7).withValues(alpha: 0.12);
        fg = const Color(0xFF0284C7);
        break;
      case 'completed':
        bg = const Color(0xFF10B981).withValues(alpha: 0.14);
        fg = const Color(0xFF16A34A);
        break;
      case 'cancelled':
      case 'removed':
        bg = const Color(0xFFEF4444).withValues(alpha: 0.14);
        fg = const Color(0xFFEF4444);
        break;
      case 'skipped':
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.14);
        fg = const Color(0xFFD97706);
        break;
      default:
        bg = Colors.grey.withValues(alpha: 0.1);
        fg = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: s == 'called'
            ? Border.all(color: fg.withValues(alpha: 0.4), width: 1)
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
