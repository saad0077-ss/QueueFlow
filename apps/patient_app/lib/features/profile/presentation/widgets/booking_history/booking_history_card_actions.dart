import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingHistoryCardActions extends StatelessWidget {
  final bool isUpcoming;
  final VoidCallback? onTrackQueue;
  final VoidCallback? onRateVisit;
  final VoidCallback? onBookAgain;

  const BookingHistoryCardActions({
    super.key,
    required this.isUpcoming,
    this.onTrackQueue,
    this.onRateVisit,
    this.onBookAgain,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isUpcoming && onTrackQueue != null)
          ElevatedButton(
            onPressed: onTrackQueue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
