import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueHistoryHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const QueueHistoryHeader({
    super.key,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Live Queue History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Joined tokens, estimated waits & visits',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Refresh button
          InkWell(
            onTap: onRefresh,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
