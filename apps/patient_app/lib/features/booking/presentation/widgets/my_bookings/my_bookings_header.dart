import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'my_bookings_filter_bar.dart';

class MyBookingsHeader extends StatelessWidget {
  final bool isLaptop;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterChanged;

  const MyBookingsHeader({
    super.key,
    required this.isLaptop,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        if (!isLaptop) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Bookings',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: colors.textPrimary,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        MyBookingsFilterBar(
          selectedFilterIndex: selectedFilterIndex,
          onFilterChanged: onFilterChanged,
        ),
      ],
    );
  }
}
