import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueHistoryStatsBar extends StatelessWidget {
  final int totalJoined;
  final int totalServed;
  final String avgWait;

  const QueueHistoryStatsBar({
    super.key,
    required this.totalJoined,
    required this.totalServed,
    this.avgWait = '--',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Stat 1: Joined
          Expanded(
            child: _StatTile(
              count: '$totalJoined',
              label: 'JOINED',
              countColor: AppColors.primary,
              borderColor: colors.border,
              bgColor: colors.surface,
              textColor: colors.textMuted,
            ),
          ),
          const SizedBox(width: 8),

          // Stat 2: Served
          Expanded(
            child: _StatTile(
              count: '$totalServed',
              label: 'SERVED',
              countColor: const Color(0xFF10B981),
              borderColor: colors.border,
              bgColor: colors.surface,
              textColor: colors.textMuted,
            ),
          ),
          const SizedBox(width: 8),

          // Stat 3: Avg Wait
          Expanded(
            child: _StatTile(
              count: avgWait,
              label: 'AVG WAIT',
              countColor: const Color(0xFFF59E0B),
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
