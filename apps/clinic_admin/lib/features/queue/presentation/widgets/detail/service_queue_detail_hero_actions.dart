import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ServiceQueueDetailHeroActions extends StatelessWidget {
  final bool hasWaiting;
  final bool isClosed;
  final VoidCallback onCallNext;
  final VoidCallback onAddWalkIn;
  final VoidCallback onToggleClosed;

  const ServiceQueueDetailHeroActions({
    super.key,
    required this.hasWaiting,
    required this.isClosed,
    required this.onCallNext,
    required this.onAddWalkIn,
    required this.onToggleClosed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: hasWaiting && !isClosed ? onCallNext : null,
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: Text(
            'Call Next In Line',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: colors.textMuted.withValues(alpha: 0.2),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        OutlinedButton.icon(
          onPressed: isClosed ? null : onAddWalkIn,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(
            'Add Walk-In Patient',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            side: BorderSide(color: colors.border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onToggleClosed,
          icon: Icon(
            isClosed ? Icons.lock_open_rounded : Icons.event_busy_rounded,
            size: 18,
          ),
          label: Text(
            isClosed ? 'Reopen Queue' : 'Close Queue for Today',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: isClosed ? const Color(0xFF10B981) : colors.textPrimary,
            side: BorderSide(color: isClosed ? const Color(0xFF10B981) : colors.border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
