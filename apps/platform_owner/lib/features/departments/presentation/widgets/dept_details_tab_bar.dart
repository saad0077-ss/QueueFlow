import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeptDetailsTabBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final int catalogCount;
  final int pendingRequestsCount;

  const DeptDetailsTabBar({super.key, required this.activeTab, required this.onTabChanged, required this.catalogCount, this.pendingRequestsCount = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _tab(0, '🩺', 'Sub-Departments & Services Catalog', catalogCount.toString()),
            const SizedBox(width: 14),
            _tab(1, '📩', 'Clinic Staff Requests', pendingRequestsCount.toString()),
            const SizedBox(width: 14),
            _tab(2, '⚙️', 'Specialty Rules & Configuration', null),
          ],
        ),
      ),
    );
  } 

  Widget _tab(int idx, String icon, String title, String? badge) {
    final sel = activeTab == idx;
    return InkWell(
      onTap: () => onTabChanged(idx),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: sel ? const Color(0xFF3B82F6) : Colors.transparent, width: 2.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 7),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: sel ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0)),
            ),
            if (badge != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                ),
              ),
            ],
          ],
        ),   
      ),
    );
  }
}
