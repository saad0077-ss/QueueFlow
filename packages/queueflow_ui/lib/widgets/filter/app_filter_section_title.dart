import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFilterSectionTitle extends StatelessWidget {
  final String title;

  const AppFilterSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF94A3B8),
        letterSpacing: 0.6,
      ),
    );
  }
}
