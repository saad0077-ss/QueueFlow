import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueTableHeader extends StatelessWidget {
  final String actionLabel;
  final IconData actionIcon;
  final bool actionEnabled;
  final VoidCallback onCallNext;

  const QueueTableHeader({
    super.key,
    required this.actionLabel,
    required this.actionIcon,
    required this.actionEnabled,
    required this.onCallNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Patient Queue',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              'Click any row to open patient actions',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: actionEnabled ? onCallNext : null,
            icon: Icon(actionIcon, size: 16),
            label: Text(
              actionLabel,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: colors.textMuted.withValues(alpha: 0.15),
              disabledForegroundColor: colors.textMuted,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
