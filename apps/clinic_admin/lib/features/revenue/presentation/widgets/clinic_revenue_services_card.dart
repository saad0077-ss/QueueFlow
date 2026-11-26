import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import '../utils/clinic_revenue_formatter.dart';
import 'clinic_revenue_card_shell.dart';

/// Ranks clinical services by settled revenue contribution.
class ClinicRevenueServicesCard extends StatelessWidget {
  final List<RevenueServiceStat> services;

  const ClinicRevenueServicesCard({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final top = services.take(5).toList();

    return ClinicRevenueCardShell(
      title: 'Top Earning Services',
      subtitle: 'Medical services generating the highest fee revenue',
      child: top.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No paid service earnings recorded yet.',
                  style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
                ),
              ),
            )
          : Column(
              children: [
                for (int i = 0; i < top.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _ServiceRow(stat: top[i]),
                ],
              ],
            ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final RevenueServiceStat stat;
  const _ServiceRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.serviceName,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${stat.departmentName} • ${stat.visits} visits',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              ClinicRevenueFormatter.formatInr(stat.revenue),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (stat.sharePercent / 100).clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: colors.border.withValues(alpha: 0.35),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
          ),
        ),
      ],
    );
  }
}
