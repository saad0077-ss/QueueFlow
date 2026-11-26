import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/patient_queue_history_entity.dart';

class QueueHistoryMetaStrip extends StatelessWidget {
  final PatientQueueHistoryEntity item;

  const QueueHistoryMetaStrip({super.key, required this.item});

  Widget _chip(AppColorsExtension colors, IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12.5, color: colors.textMuted),
      const SizedBox(width: 4),
      Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.textMuted,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          _chip(colors, Icons.calendar_today_rounded, item.date),
          _chip(colors, Icons.schedule_rounded, 'Joined ${item.joinedTime}'),
          if (item.waitTime != null && item.waitTime!.isNotEmpty)
            _chip(colors, Icons.hourglass_bottom_rounded, 'Waited ${item.waitTime}'),
        ],
      ),
    );
  }
}
