import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors_extension.dart';

class AppFilterSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onClear;

  const AppFilterSearchField({
    super.key,
    required this.hintText,
    this.onChanged,
    this.controller,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasText = controller != null && controller!.text.isNotEmpty;

    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: colors.primary,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 12.5),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: colors.surfaceSecondary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: colors.textMuted, fontSize: 12.5),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.textMuted,
            size: 18,
          ),
          suffixIcon: hasText && onClear != null
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  color: colors.textMuted,
                  onPressed: onClear,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
