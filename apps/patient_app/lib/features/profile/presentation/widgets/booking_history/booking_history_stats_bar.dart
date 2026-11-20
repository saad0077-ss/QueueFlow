import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingHistoryStatsBar extends StatelessWidget {
  final int totalVisits;
  final int completedCount;
  final int upcomingCount;

  const BookingHistoryStatsBar({
    super.key,
    required this.totalVisits,
    required this.completedCount,
    required this.upcomingCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Stat 1: Total Visits
          Expanded(
            child: _StatTile(
              count: '$totalVisits',
              label: 'TOTAL VISITS',
              countColor: AppColors.primary,
              borderColor: colors.border,
              bgColor: colors.surface,
              textColor: colors.textMuted,
            ),
          ),
          const SizedBox(width: 8),

          // Stat 2: Completed
          Expanded(
            child: _StatTile(
              count: '$completedCount',
              label: 'COMPLETED',
              countColor: const Color(0xFF10B981),
              borderColor: colors.border,
              bgColor: colors.surface,
              textColor: colors.textMuted,
            ),
          ),
          const SizedBox(width: 8),

          // Stat 3: Upcoming
          Expanded(
            child: _StatTile(
              count: '$upcomingCount',
              label: 'UPCOMING',
              countColor: colors.textPrimary,
              borderColor: colors.border,
              bgColor: colors.surface,
              textColor: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String count;
  final String label;
  final Color countColor;
  final Color borderColor;
  final Color bgColor;
  final Color textColor;

  const _StatTile({
    required this.count,
    required this.label,
    required this.countColor,
    required this.borderColor,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: countColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
