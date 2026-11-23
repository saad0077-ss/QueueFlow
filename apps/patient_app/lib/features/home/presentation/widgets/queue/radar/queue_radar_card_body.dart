import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../../../core/widgets/clinic_photo.dart';
import '../../../../../../core/widgets/distance_builder.dart';
import '../../../../domain/entities/clinic_entity.dart';
import '../models/live_clinic_queue_info.dart';
import 'live_pulsing_dot.dart';
import 'queue_radar_info_chip.dart';
import 'queue_radar_join_button.dart';
import 'queue_radar_phase_helper.dart';

class QueueRadarCardBody extends StatelessWidget {
  final ClinicEntity clinic;
  final LiveInfo info;
  final void Function(ClinicEntity clinic, LiveServiceQueue? target)
  onJoinClinic;

  const QueueRadarCardBody({
    super.key,
    required this.clinic,
    required this.info,
    required this.onJoinClinic,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = context.isDarkMode ? const Color(0xFF2DD4BF) : colors.accent;
    final waitMin = info.waiting * 5 > 0 ? info.waiting * 5 : 5;
    final started = info.phase == LiveQueuePhase.serving;
    final notice = QueueRadarPhaseHelper.phaseNotice(info);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDarkMode ? 0.2 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopRow(context, colors, accent),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (started)
                  Row(
                    children: [
                      Text(
                        'Now serving: ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                      Text(
                        info.serving,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(notice.$1, size: 14, color: colors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        notice.$2,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                if (started)
                  Text(
                    '~$waitMin min wait',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          QueueRadarJoinButton(
            clinic: clinic,
            target: info.liveQueues.firstOrNull,
            onJoin: () => onJoinClinic(clinic, info.liveQueues.firstOrNull),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, dynamic colors, Color accent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 42,
            height: 42,
            child: ClinicPhoto(
              clinicId: clinic.id,
              imageVersion: clinic.imageVersion,
              imageUrl: clinic.imageUrl,
              placeholder: Container(
                color: colors.primaryTint,
                alignment: Alignment.center,
                child: Text(
                  clinic.initials,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clinic.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              DistanceBuilder(
                clinic: clinic,
                builder: (ctx, dist) => dist.isEmpty
                    ? const SizedBox.shrink()
                    : QueueRadarInfoChip(
                        icon: Icons.location_on_outlined,
                        label: dist,
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: context.isDarkMode
                ? const Color(0xFF133633)
                : colors.accentTint,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LivePulsingDot(),
              const SizedBox(width: 4),
              Text(
                QueueRadarPhaseHelper.phaseLabel(info),
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
