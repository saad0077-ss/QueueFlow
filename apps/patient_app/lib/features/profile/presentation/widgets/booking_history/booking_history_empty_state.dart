import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingHistoryEmptyState extends StatelessWidget {
  const BookingHistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text('📅', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            'No appointments found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No booking records match your current filter.',
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
