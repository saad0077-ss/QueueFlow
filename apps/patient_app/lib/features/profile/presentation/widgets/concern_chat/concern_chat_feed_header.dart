import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Header strip for the Care Desk Discussion chat panel.
class ConcernChatFeedHeader extends StatelessWidget {
  final int messageCount;
  final bool isResolved;
  final VoidCallback onToggleResolve;

  const ConcernChatFeedHeader({
    super.key,
    required this.messageCount,
    required this.isResolved,
    required this.onToggleResolve,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final actionColor =
        isResolved ? const Color(0xFF2563EB) : const Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          const Text('💬', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Care Desk Discussion ($messageCount)',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onToggleResolve,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: isResolved ? 0.1 : 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: actionColor, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isResolved
                        ? Icons.refresh_rounded
                        : Icons.check_circle_rounded,
                    size: 13,
                    color: actionColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isResolved ? 'Reopen Concern' : 'Mark as Resolved',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: actionColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
