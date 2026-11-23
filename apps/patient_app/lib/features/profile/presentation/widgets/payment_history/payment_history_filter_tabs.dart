import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PaymentHistoryFilterTabs extends StatelessWidget {
  final String activeFilter;
  final int countAll;
  final int countQueue;
  final int countAppt;
  final int countRefunded;
  final ValueChanged<String> onFilterSelected;

  const PaymentHistoryFilterTabs({
    super.key,
    required this.activeFilter,
    required this.countAll,
    required this.countQueue,
    required this.countAppt,
    required this.countRefunded,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _tab(context, id: 'all', label: 'All ($countAll)'),
          _tab(context, id: 'queue', label: '🎟️ Queue Tokens ($countQueue)'),
          _tab(context, id: 'appointment', label: '📅 Bookings ($countAppt)'),
          _tab(context, id: 'refunded', label: '↺ Refunded ($countRefunded)'),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context, {
    required String id,
    required String label,
  }) {
    final colors = context.colors;
    final isSelected = activeFilter == id;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onFilterSelected(id),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
