import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Case- and whitespace-insensitive key used to detect duplicate names/codes.
String catalogKey(String value) => value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

/// Returns the first name that appears more than once in [names], or null.
String? firstDuplicateName(Iterable<String> names) {
  final seen = <String>{};
  for (final n in names) {
    if (!seen.add(catalogKey(n))) return n.trim();
  }
  return null;
}

/// Inline red error banner shown inside the add forms.
class FormErrorText extends StatelessWidget {
  final String message;

  const FormErrorText(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFF87171)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFFFCA5A5))),
          ),
        ],
      ),
    );
  }
}
