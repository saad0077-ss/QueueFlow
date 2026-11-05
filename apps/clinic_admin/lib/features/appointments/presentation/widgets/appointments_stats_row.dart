import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_appointment_entity.dart';

/// Summary KPI cards shown above the appointments list.
class AppointmentsStatsRow extends StatelessWidget {
  final List<ClinicAppointmentEntity> appointments;

  const AppointmentsStatsRow({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = appointments.length;
    final upcoming = appointments
        .where((a) => a.isUpcoming || a.isConfirmed)
        .length;
    final checkedIn = appointments.where((a) => a.isCheckedIn).length;
    final completed = appointments.where((a) => a.isCompleted).length;
    final cancelled = appointments.where((a) => a.isCancelled).length;

    final stats = [
      _Stat(
        'Total',
        total,
        Icons.event_note_rounded,
        colors.primary,
        colors.primaryTint,
      ),
      _Stat(
        'Upcoming',
        upcoming,
        Icons.schedule_rounded,
        colors.info,
        colors.infoTint,
      ),
      _Stat(
        'Checked In',
        checkedIn,
        Icons.how_to_reg_rounded,
        colors.success,
        colors.successTint,
      ),
      _Stat(
        'Completed',
        completed,
        Icons.check_circle_outline_rounded,
        colors.textMuted,
        colors.surfaceSecondary,
      ),
      _Stat(
        'Cancelled',
        cancelled,
        Icons.cancel_outlined,
        colors.error,
        colors.errorTint,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final columns = w >= 900 ? 5 : (w >= 560 ? 3 : 2);
        const gap = 12.0;
        final itemWidth = (w - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final s in stats)
              SizedBox(
                width: itemWidth,
                child: _StatCard(stat: s),
              ),
          ],
        );
      },
    );
  }
}

class _Stat {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color tint;

  const _Stat(this.label, this.value, this.icon, this.color, this.tint);
}

class _StatCard extends StatelessWidget {
  final _Stat stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: stat.tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, size: 19, color: stat.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stat.value}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
