import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Top-bar search bar for searching patients and appointments.
class ClinicSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const ClinicSearchBar({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(10);

    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: colors.primary,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.inter(fontSize: 13.5, color: colors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: colors.surfaceSecondary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          hintText: 'Search patients, appointments...',
          hintStyle: GoogleFonts.inter(fontSize: 13.5, color: colors.textMuted),
          prefixIcon:
              Icon(Icons.search_rounded, color: colors.textMuted, size: 19),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
          border: outline(colors.border),
          enabledBorder: outline(colors.border),
          focusedBorder: outline(colors.primary, 1.5),
        ),
      ),
    );
  }
}
