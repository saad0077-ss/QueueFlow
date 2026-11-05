import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class DeptDetailsTabBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final int catalogCount;
  final int pendingRequestsCount;

  const DeptDetailsTabBar({super.key, required this.activeTab, required this.onTabChanged, required this.catalogCount, this.pendingRequestsCount = 0});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _tab(context, 0, '🩺', 'Sub-Departments & Services Catalog', catalogCount.toString()),
            const SizedBox(width: 14),
            _tab(context, 1, '📩', 'Clinic Staff Requests', pendingRequestsCount.toString()),
            const SizedBox(width: 14),
            _tab(context, 2, '⚙️', 'Specialty Rules & Configuration', null),
          ],
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, int idx, String icon, String title, String? badge) {
    final colors = context.colors;
    final sel = activeTab == idx;
    return InkWell(
      onTap: () => onTabChanged(idx),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: sel ? colors.primary : Colors.transparent, width: 2.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 7),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: sel ? colors.primary : colors.textMuted),
            ),
            if (badge != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: colors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
