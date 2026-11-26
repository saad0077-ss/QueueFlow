import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import '../utils/clinic_revenue_formatter.dart';
import 'clinic_revenue_card_shell.dart';

/// Displays revenue generated per consulting doctor in the clinic.
class ClinicRevenueDoctorsCard extends StatelessWidget {
  final List<RevenueDoctorStat> doctors;

  const ClinicRevenueDoctorsCard({super.key, required this.doctors});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final top = doctors.take(5).toList();

    return ClinicRevenueCardShell(
      title: 'Revenue by Doctor',
      subtitle: 'Consulting fee contribution across practicing doctors',
      child: top.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No settled doctor consultations in this timeframe.',
                  style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
                ),
              ),
            )
          : Column(
              children: [
                for (int i = 0; i < top.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _DoctorRevenueRow(rank: i + 1, stat: top[i]),
                ],
              ],
            ),
    );
  }
}

class _DoctorRevenueRow extends StatelessWidget {
  final int rank;
  final RevenueDoctorStat stat;

  const _DoctorRevenueRow({required this.rank, required this.stat});

  String _initials(String name) {
    final clean = name.replaceAll('Dr.', '').trim();
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.isEmpty
        ? 'DR'
        : clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: colors.isDark ? 0.5 : 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: colors.primary.withValues(alpha: 0.16),
            child: Text(
              _initials(stat.doctorName),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: colors.primaryLight,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.doctorName,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '#$rank • ${stat.specialty} • ${stat.consultations} visits',
                  style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ClinicRevenueFormatter.formatInr(stat.revenue),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
