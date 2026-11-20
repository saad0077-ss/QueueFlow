import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';

class ServiceQueueCardServingBox extends StatelessWidget {
  final ClinicQueueItemEntity? servingItem;

  const ServiceQueueCardServingBox({super.key, this.servingItem});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111A2C) : colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: servingItem != null
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : colors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENTLY SERVING',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: colors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          if (servingItem != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    servingItem!.token,
                    style: GoogleFonts.robotoMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    servingItem!.patientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              'No patient currently serving',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                color: colors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}
