import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

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
    final colors = context.colors;
    const tabs = ['Clinic Subscriptions', 'Platform Plan Tiers', 'Invoice Ledger'];

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
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
                    color: isSelected ? colors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tabs[i],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? colors.primaryLight : colors.textMuted,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
