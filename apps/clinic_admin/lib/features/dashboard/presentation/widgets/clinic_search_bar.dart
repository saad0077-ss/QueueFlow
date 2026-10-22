import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Top-bar search bar for searching patients and appointments.
class ClinicSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const ClinicSearchBar({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 19),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: const Color(0xFF38BDF8),
              style: GoogleFonts.inter(fontSize: 13.5, color: Colors.white),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: 'Search patients, appointments...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
