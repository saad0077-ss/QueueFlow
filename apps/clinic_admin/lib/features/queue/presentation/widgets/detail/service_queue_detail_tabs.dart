import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ServiceQueueDetailTabs extends StatelessWidget {
  final String activeTab;
  final int activeCount;
  final int waitingCount;
  final int servingCount;
  final int completedSkippedCount;
  final int allCount;
  final ValueChanged<String> onTabChanged;

  const ServiceQueueDetailTabs({
    super.key,
    required this.activeTab,
    required this.activeCount,
    required this.waitingCount,
    required this.servingCount,
    required this.completedSkippedCount,
    required this.allCount,
    required this.onTabChanged,
  });

  Widget _tabPill(BuildContext context, {required String id, required String label}) {
    final colors = context.colors;
    final isActive = activeTab == id;

    return InkWell(
      onTap: () => onTabChanged(id),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? colors.primary : colors.textMuted,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tabPill(context, id: 'active', label: 'Active Queue ($activeCount)'),
            _tabPill(context, id: 'waiting', label: 'Waiting ($waitingCount)'),
            _tabPill(context, id: 'called', label: 'Serving ($servingCount)'),
            _tabPill(
              context,
              id: 'completed',
              label: 'Completed / Skipped ($completedSkippedCount)',
            ),
            _tabPill(context, id: 'all', label: 'All ($allCount)'),
          ],
        ),
      ),
    );
  }
}
