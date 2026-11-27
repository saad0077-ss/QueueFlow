import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import '../utils/clinic_revenue_formatter.dart';
import 'clinic_revenue_card_shell.dart';

/// Displays Online UPI, Counter Cash, and Pending Receivables payment mix.
class ClinicRevenueChannelsCard extends StatelessWidget {
  final List<RevenueChannelStat> channels;

  const ClinicRevenueChannelsCard({super.key, required this.channels});

  static const _accents = [
    Color(0xFF00D2FF),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
  ];

  @override
  Widget build(BuildContext context) {
    return ClinicRevenueCardShell(
      title: 'Collection Channels',
      subtitle: 'Settlement split across Razorpay & walk-in queue',
      child: Column(
        children: [
          for (int i = 0; i < channels.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _ChannelProgressRow(
              stat: channels[i],
              accent: _accents[i % _accents.length],
            ),
          ],
        ],
      ),
    );
  }
}

class _ChannelProgressRow extends StatelessWidget {
  final RevenueChannelStat stat;
  final Color accent;

  const _ChannelProgressRow({required this.stat, required this.accent});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ratio = (stat.sharePercent / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: colors.isDark ? 0.5 : 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stat.label,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ClinicRevenueFormatter.formatInr(stat.amount),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: colors.border.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stat.count} visit${stat.count == 1 ? '' : 's'}',
                style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
              ),
              Text(
                '${stat.sharePercent.toStringAsFixed(1)}% share',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
