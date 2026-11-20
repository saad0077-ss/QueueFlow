import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';

class ServiceQueueCardMetrics extends StatelessWidget {
  final List<ClinicQueueItemEntity> waitingItems;
  final int estWaitMinutes;

  const ServiceQueueCardMetrics({
    super.key,
    required this.waitingItems,
    required this.estWaitMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('👥', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary),
                    children: [
                      TextSpan(
                        text: '${waitingItems.length} ',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: 'waiting',
                        style: TextStyle(color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('⏰', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 5),
                Text(
                  '~$estWaitMinutes mins wait',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (waitingItems.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Next: ',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                ),
              ),
              for (final w in waitingItems.take(3)) ...[
                Container(
                  margin: const EdgeInsets.only(right: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    w.token,
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
              if (waitingItems.length > 3)
                Text(
                  '+${waitingItems.length - 3}',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: colors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
