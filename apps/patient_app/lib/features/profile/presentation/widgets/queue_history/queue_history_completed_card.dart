import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/patient_queue_history_entity.dart';
import 'queue_history_card_parts.dart';
import 'queue_history_doctor_row.dart';
import 'queue_history_meta_strip.dart';

class QueueHistoryCompletedCard extends StatelessWidget {
  final PatientQueueHistoryEntity item;
  final VoidCallback? onBookAgain;

  const QueueHistoryCompletedCard({
    super.key,
    required this.item,
    this.onBookAgain,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCancelled = item.isCancelled;
    final statusColor =
        isCancelled ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCancelled ? statusColor.withValues(alpha: 0.28) : colors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
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
              Flexible(child: QueueHistoryTokenBadge(token: item.token)),
              const SizedBox(width: 8),
              QueueHistoryStatusPill(
                color: statusColor,
                label: isCancelled ? '✕ Cancelled' : '✓ Served',
              ),
            ],
          ),
          const SizedBox(height: 12),
          QueueHistoryClinicRow(item: item),
          const SizedBox(height: 12),
          QueueHistoryMetaStrip(item: item),
          if (onBookAgain != null || item.doctorName.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: QueueHistoryDoctorRow(
                    doctorName: item.doctorName,
                    photoUrl: item.doctorPhotoUrl,
                  ),
                ),
                if (onBookAgain != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onBookAgain,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_repeat_rounded, size: 14, color: colors.primary),
                          const SizedBox(width: 5),
                          Text(
                            'Book Clinic Again',
                            style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
