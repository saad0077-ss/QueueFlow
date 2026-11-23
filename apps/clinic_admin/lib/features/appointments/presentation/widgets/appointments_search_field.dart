import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class AppointmentsSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const AppointmentsSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search patient, booking ID, doctor, phone...',
          hintStyle: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: colors.textMuted,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  color: colors.textMuted,
                  onPressed: onClear,
                ),
          filled: true,
          fillColor: colors.surfaceSecondary,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.primary),
          ),
        ),
      ),
    );
  }
}
