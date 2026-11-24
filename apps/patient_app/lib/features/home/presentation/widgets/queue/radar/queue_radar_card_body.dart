import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../domain/entities/clinic_entity.dart';
import '../models/live_clinic_queue_info.dart';
import 'queue_radar_card_header.dart';
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
          QueueRadarCardHeader(clinic: clinic, info: info),
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
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Now serving: ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: colors.textMuted,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            info.serving,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: Row(
                      children: [
                        Icon(notice.$1, size: 14, color: colors.textMuted),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            notice.$2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
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
            info: info,
            onJoin: () => onJoinClinic(clinic, info.liveQueues.firstOrNull),
          ),
        ],
      ),
    );
  }
}
