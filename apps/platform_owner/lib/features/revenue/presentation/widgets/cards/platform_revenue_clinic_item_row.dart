import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'platform_revenue_clinic_row_widgets.dart';

class PlatformRevenueClinicItemRow extends StatelessWidget {
  final Map<String, dynamic> item;

  const PlatformRevenueClinicItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    final name = (item['name'] ?? 'Clinic').toString();
    final plan = (item['planName'] ?? 'Solo Doctor Plan').toString();
    final fee = (item['monthlyFee'] as num?)?.toInt() ?? 999;
    final category = (item['category'] ?? 'General Practice').toString();
    final city = (item['city'] ?? 'Active Site').toString();
    final doctors = (item['doctorsCount'] as num?)?.toInt() ?? 1;

    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .where((w) => w.isNotEmpty)
              .take(2)
              .map((w) => w[0])
              .join()
              .toUpperCase()
        : 'QC';

    final isMulti = plan.toLowerCase().contains('multi');
    final isEnterprise =
        plan.toLowerCase().contains('unlimited') ||
        plan.toLowerCase().contains('enterprise');
    final accent = isEnterprise
        ? const Color(0xFF0284C7)
        : (isMulti ? const Color(0xFF10B981) : const Color(0xFFF59E0B));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          PlatformRevenueClinicRowWidgets.buildAvatar(initials, accent),
          const SizedBox(width: 12),
          Expanded(
            child: PlatformRevenueClinicRowWidgets.buildInfo(
              name: name,
              plan: plan,
              subtitle: '$category • $city • $doctors Dr',
              accent: accent,
              colors: colors,
            ),
          ),
          const SizedBox(width: 12),
          PlatformRevenueClinicRowWidgets.buildTrailing(fee, colors),
        ],
      ),
    );
  }
}
