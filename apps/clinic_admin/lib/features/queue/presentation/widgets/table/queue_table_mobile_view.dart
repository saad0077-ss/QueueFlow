import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';
import 'queue_table_status_badge.dart';

class QueueTableMobileView extends StatelessWidget {
  final List<ClinicQueueItemEntity> items;
  final ValueChanged<ClinicQueueItemEntity> onSelectPatient;

  const QueueTableMobileView({
    super.key,
    required this.items,
    required this.onSelectPatient,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: context.colors.border),
      itemBuilder: (context, index) {
        final item = items[index];
        final colors = context.colors;
        final isCalled = item.isCalled;

        return InkWell(
          onTap: () => onSelectPatient(item),
          child: Container(
            color: isCalled
                ? colors.primaryTint.withValues(alpha: 0.3)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.token,
                    style: GoogleFonts.robotoMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.patientName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.serviceName} · ${item.joinedTime}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                QueueTableStatusBadge(status: item.status),
              ],
            ),
          ),
        );
      },
    );
  }
}
