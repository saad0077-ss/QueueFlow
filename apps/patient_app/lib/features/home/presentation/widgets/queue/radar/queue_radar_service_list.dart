import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../domain/entities/clinic_entity.dart';
import '../models/live_clinic_queue_info.dart';
import 'queue_radar_join_button.dart';

class QueueRadarServiceList extends StatelessWidget {
  final ClinicEntity clinic;
  final LiveInfo info;
  final void Function(ClinicEntity clinic, LiveServiceQueue? target)
  onJoinClinic;

  const QueueRadarServiceList({
    super.key,
    required this.clinic,
    required this.info,
    required this.onJoinClinic,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = context.isDarkMode ? const Color(0xFF2DD4BF) : colors.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final q in info.liveQueues)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (q.department.isNotEmpty)
                            Text(
                              q.department,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          Text(
                            q.service,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      q.serving
                          ? 'Now serving ${q.servingToken}'
                          : 'Not started',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${q.waiting} waiting'
                  '${q.waiting > 0 ? ' · ~${q.waiting * 5} min wait' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                QueueRadarJoinButton(
                  clinic: clinic,
                  target: q,
                  onJoin: () => onJoinClinic(clinic, q),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
