import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

enum HelpSupportTab { concerns, raise, faq }

class HelpSupportNavTabs extends StatelessWidget {
  final HelpSupportTab activeTab;
  final int concernsCount;
  final ValueChanged<HelpSupportTab> onTabChanged;

  const HelpSupportNavTabs({
    super.key,
    required this.activeTab,
    required this.concernsCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTab(
            label: '📋 Concerns',
            badge: concernsCount > 0 ? '$concernsCount' : null,
            isSelected: activeTab == HelpSupportTab.concerns,
            onTap: () => onTabChanged(HelpSupportTab.concerns),
            colors: colors,
          ),
          _buildTab(
            label: '➕ Raise Concern',
            isSelected: activeTab == HelpSupportTab.raise,
            onTap: () => onTabChanged(HelpSupportTab.raise),
            colors: colors,
          ),
          _buildTab(
            label: '💡 FAQs & Help',
            isSelected: activeTab == HelpSupportTab.faq,
            onTap: () => onTabChanged(HelpSupportTab.faq),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    String? badge,
    required bool isSelected,
    required VoidCallback onTap,
    required AppColorsExtension colors,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? colors.textPrimary : colors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0072FF).withAlpha(30)
                        : colors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? const Color(0xFF0072FF)
                          : colors.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
