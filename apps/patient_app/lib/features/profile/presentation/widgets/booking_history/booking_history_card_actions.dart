import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingHistoryCardActions extends StatelessWidget {
  final bool isUpcoming;
  final bool canJoinQueue;
  final String? queueStatusHint;
  final VoidCallback? onTrackQueue;
  final VoidCallback? onRateVisit;
  final VoidCallback? onBookAgain;

  const BookingHistoryCardActions({
    super.key,
    required this.isUpcoming,
    this.canJoinQueue = false,
    this.queueStatusHint,
    this.onTrackQueue,
    this.onRateVisit,
    this.onBookAgain,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final showHint =
        !canJoinQueue && (queueStatusHint?.trim().isNotEmpty ?? false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isUpcoming && onTrackQueue != null) ...[
          if (showHint) ...[
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      queueStatusHint!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Tooltip(
            message: showHint ? queueStatusHint! : 'Open live queue',
            child: ElevatedButton(
              onPressed: canJoinQueue ? onTrackQueue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: colors.textMuted.withValues(alpha: 0.16),
                disabledForegroundColor: colors.textMuted.withValues(alpha: 0.75),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Join / Track Queue',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
        if (!isUpcoming) ...[
          if (onRateVisit != null) ...[
            OutlinedButton(
              onPressed: onRateVisit,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                ),
                backgroundColor: const Color(0xFFF59E0B)
                    .withValues(alpha: 0.08),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '⭐ Rate Visit',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (onBookAgain != null)
            OutlinedButton(
              onPressed: onBookAgain,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Book Again',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
