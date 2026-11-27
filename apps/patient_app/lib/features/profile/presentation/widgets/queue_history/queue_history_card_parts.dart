import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/clinic_profile_avatar.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/patient_queue_history_entity.dart';

class QueueHistoryTokenBadge extends StatelessWidget {
  final String token;
  final bool filled;

  const QueueHistoryTokenBadge({
    super.key,
    required this.token,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: filled ? 10 : 9, vertical: 4.5),
      decoration: BoxDecoration(
        gradient: filled ? AppColors.primaryGradient : null,
        color: filled ? null : colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: filled
            ? null
            : Border.all(color: colors.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.confirmation_number_rounded,
            size: 12.5,
            color: filled ? Colors.white : colors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            token,
            maxLines: 1,
            softWrap: false,
            style: GoogleFonts.robotoMono(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: filled ? Colors.white : colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class QueueHistoryStatusPill extends StatelessWidget {
  final Color color;
  final String label;

  const QueueHistoryStatusPill({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}

class QueueHistoryClinicRow extends StatelessWidget {
  final PatientQueueHistoryEntity item;

  const QueueHistoryClinicRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        ClinicProfileAvatar(
          clinicId: item.clinicId,
          clinicName: item.clinicName,
          imageVersion: item.clinicImageVersion,
          imageUrl: item.clinicImageUrl,
          size: 44,
          borderRadius: 12,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.clinicName,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: colors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${item.departmentName} · ${item.serviceName}',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
