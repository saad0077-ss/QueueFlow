import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class NotificationFilterBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onFilterChanged;

  const NotificationFilterBar({
    super.key,
    required this.selectedIndex,
    required this.onFilterChanged,
  });

  static const _labels = ['All', 'Queue Alerts', 'Bookings', 'Support'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < _labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => onFilterChanged(i),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? colors.primary
                        : colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedIndex == i ? colors.primary : colors.border,
                    ),
                  ),
                  child: Text(
                    _labels[i],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: selectedIndex == i
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: selectedIndex == i ? Colors.white : colors.textMuted,
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
