import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/patient_queue_history_entity.dart';
import 'queue_history_card_parts.dart';
import 'queue_history_doctor_row.dart';

class QueueHistoryActiveCard extends StatelessWidget {
  final PatientQueueHistoryEntity item;
  final VoidCallback? onTrackLive;

  const QueueHistoryActiveCard({
    super.key,
    required this.item,
    this.onTrackLive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.65), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: QueueHistoryTokenBadge(token: item.token, filled: true)),
              const SizedBox(width: 8),
              const QueueHistoryStatusPill(color: Color(0xFF10B981), label: '● Active'),
            ],
          ),
          const SizedBox(height: 12),
          QueueHistoryClinicRow(item: item),
          if (item.doctorName.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            QueueHistoryDoctorRow(
              doctorName: item.doctorName,
              photoUrl: item.doctorPhotoUrl,
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Position: ${item.position} ahead · Wait: ~${item.estWaitMin}m',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                    ),
                  ),
                ),
                if (onTrackLive != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onTrackLive,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Track Live →',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
