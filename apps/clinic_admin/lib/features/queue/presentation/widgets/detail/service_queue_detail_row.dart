import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';
import 'service_queue_detail_row_actions.dart';
import 'service_queue_status_badge.dart';

class ServiceQueueDetailRow extends StatelessWidget {
  final ClinicQueueItemEntity item;
  final List<ClinicQueueItemEntity> sWaiting;
  final ValueChanged<ClinicQueueItemEntity> onSelectPatient;
  final ValueChanged<String> onCallSpecific;
  final ValueChanged<String> onComplete;
  final ValueChanged<String> onSkip;

  static const double wIndex = 40;
  static const double wActions = 290;

  const ServiceQueueDetailRow({
    super.key,
    required this.item,
    required this.sWaiting,
    required this.onSelectPatient,
    required this.onCallSpecific,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCalled = item.isCalled;
    final isWaiting = item.isWaiting;
    final waitPos = isWaiting ? sWaiting.indexOf(item) + 1 : 0;
    final index = isCalled ? '⭐' : (isWaiting ? '$waitPos' : '-');

    return InkWell(
      onTap: () => onSelectPatient(item),
      child: Container(
        color: isCalled ? colors.primaryTint.withValues(alpha: 0.35) : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            SizedBox(
              width: wIndex,
              child: Text(
                index,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isCalled ? const Color(0xFF10B981) : colors.textMuted,
                ),
              ),
            ),
            Expanded(
              flex: 12,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    item.token,
                    style: GoogleFonts.robotoMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.patientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [item.phone, if (item.email.isNotEmpty) item.email]
                        .where((e) => e.isNotEmpty)
                        .join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 14,
              child: Text(
                item.joinedTime,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
            ),
            Expanded(
              flex: 13,
              child: Text(
                item.estDuration,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Expanded(
              flex: 17,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ServiceQueueStatusBadge(item: item, waitPos: waitPos),
              ),
            ),
            SizedBox(
              width: wActions,
              child: ServiceQueueDetailRowActions(
                item: item,
                onSelectPatient: onSelectPatient,
                onCallSpecific: onCallSpecific,
                onComplete: onComplete,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
