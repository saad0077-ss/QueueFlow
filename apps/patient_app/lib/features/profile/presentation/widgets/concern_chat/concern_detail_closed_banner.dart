import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Footer banner shown when a concern is resolved, allowing quick reopening.
class ConcernDetailClosedBanner extends StatelessWidget {
  final bool embedded;
  final VoidCallback onReopen;

  const ConcernDetailClosedBanner({
    super.key,
    required this.embedded,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPad = embedded
        ? 14.0
        : (MediaQuery.of(context).viewInsets.bottom > 0
              ? MediaQuery.of(context).viewInsets.bottom + 10
              : 24.0);

    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: bottomPad),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: embedded
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : null,
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: embedded
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              size: 16,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ticket Closed & Resolved',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reopen this concern to resume live messaging with care desk.',
                  style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: onReopen,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: Text(
              'Reopen',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
