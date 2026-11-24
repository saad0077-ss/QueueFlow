import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicNotificationHeader extends StatelessWidget {
  final int unread;
  final VoidCallback onMarkAllRead;
  final int selectedFilter;
  final ValueChanged<int> onFilterChanged;

  const ClinicNotificationHeader({
    super.key,
    required this.unread,
    required this.onMarkAllRead,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labels = ['All', 'Live Queue', 'Bookings', 'Support'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unread new',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (unread > 0)
              TextButton(
                onPressed: onMarkAllRead,
                child: Text(
                  'Mark all read',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < labels.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(labels[i], style: const TextStyle(fontSize: 11)),
                    selected: selectedFilter == i,
                    onSelected: (_) => onFilterChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
