import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/service_revenue_metric.dart';

class ServiceRevenueTile extends StatelessWidget {
  final ServiceRevenueMetric service;
  final int index;

  const ServiceRevenueTile({
    super.key,
    required this.service,
    required this.index,
  });

  static const _gradients = [
    [Color(0xFF38BDF8), Color(0xFF2563EB)],
    [Color(0xFF34D399), Color(0xFF059669)],
    [Color(0xFFC084FC), Color(0xFF7C3AED)],
    [Color(0xFFFBBF24), Color(0xFFEA580C)],
    [Color(0xFFFB7185), Color(0xFFE11D48)],
    [Color(0xFFA78BFA), Color(0xFF6366F1)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final grad = _gradients[index % _gradients.length];
    final pct = (service.sharePercentage / 100.0).clamp(0.02, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Info Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(service.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.serviceName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${service.visits} visits',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${service.sharePercentage}% • ₹${service.revenue.toStringAsFixed(0)})',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 7,
            width: double.infinity,
            color: colors.surfaceSecondary,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: grad),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
