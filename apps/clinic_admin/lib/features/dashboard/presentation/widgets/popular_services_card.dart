import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PopularServiceItem {
  final String name;
  final String department;
  final int count;
  final int percentage;

  const PopularServiceItem({
    required this.name,
    this.department = '',
    required this.count,
    required this.percentage,
  });
}

class PopularServicesCard extends StatelessWidget {
  final List<PopularServiceItem> services;

  const PopularServicesCard({super.key, this.services = const []});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = services;

    // Group by department (busiest department first); services keep their
    // booking order inside each group.
    final byDept = <String, List<PopularServiceItem>>{};
    for (final i in items) {
      byDept.putIfAbsent(i.department, () => []).add(i);
    }
    final groups = byDept.entries.toList()
      ..sort((a, b) {
        int sum(List<PopularServiceItem> l) =>
            l.fold<int>(0, (s, i) => s + i.count);
        return sum(b.value).compareTo(sum(a.value));
      });

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular services',
                style: GoogleFonts.inter(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                'Based on patient bookings',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No bookings yet.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: colors.textMuted,
                  ),
                ),
              ),
            )
          else
            for (var g = 0; g < groups.length; g++) ...[
              if (g > 0) const SizedBox(height: 20),
              _DepartmentGroup(
                name: groups[g].key,
                items: groups[g].value,
              ),
            ],
        ],
      ),
    );
  }
}

class _DepartmentGroup extends StatelessWidget {
  final String name;
  final List<PopularServiceItem> items;

  const _DepartmentGroup({required this.name, required this.items});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = items.fold<int>(0, (s, i) => s + i.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Department header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: colors.primaryTint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.local_hospital_outlined,
                  size: 14, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name.isEmpty ? 'Other' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ),
              Text(
                '$total booked',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Services booked under this department
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          _ServiceRow(item: items[i]),
        ],
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final PopularServiceItem item;

  const _ServiceRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.count} booked (${item.percentage}%)',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: item.percentage / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.accent],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
