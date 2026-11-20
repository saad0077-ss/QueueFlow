import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingHistorySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const BookingHistorySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search clinic, doctor or service...',
          hintStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: colors.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: colors.textMuted,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: colors.textMuted,
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
        ),
      ),
    );
  }
}
