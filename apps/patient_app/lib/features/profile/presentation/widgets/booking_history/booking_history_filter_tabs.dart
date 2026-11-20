import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingHistoryFilterTabs extends StatelessWidget {
  final int selectedIndex; // 0: All, 1: Completed, 2: Upcoming, 3: Cancelled
  final int allCount;
  final ValueChanged<int> onFilterChanged;

  const BookingHistoryFilterTabs({
    super.key,
    required this.selectedIndex,
    required this.allCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'All ($allCount)',
              isSelected: selectedIndex == 0,
              onTap: () => onFilterChanged(0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Completed',
              isSelected: selectedIndex == 1,
              onTap: () => onFilterChanged(1),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Upcoming',
              isSelected: selectedIndex == 2,
              onTap: () => onFilterChanged(2),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Cancelled',
              isSelected: selectedIndex == 3,
              onTap: () => onFilterChanged(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.primary : colors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
