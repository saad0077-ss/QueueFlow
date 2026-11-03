import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlatformBillingTabBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const PlatformBillingTabBar({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = ['Clinic Subscriptions', 'Platform Plan Tiers', 'Invoice Ledger'];

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = i == activeIndex;
          return InkWell(
            onTap: () => onTabSelected(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tabs[i],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF60A5FA) : const Color(0xFF94A3B8),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
