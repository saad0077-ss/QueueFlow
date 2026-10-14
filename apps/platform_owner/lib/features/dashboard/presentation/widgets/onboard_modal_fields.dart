import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const OnboardTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCBD5E1),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF162238),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF26354D)),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardPlanDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const OnboardPlanDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription Tier',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCBD5E1),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF162238),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF26354D)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF162238),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 18),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              items: const [
                DropdownMenuItem(value: 'solo', child: Text('Solo Doctor Plan (₹999/mo)')),
                DropdownMenuItem(value: 'multi', child: Text('Multi-Doctor Clinic Plan (₹2,999/mo)')),
                DropdownMenuItem(value: 'enterprise', child: Text('Enterprise Practice (₹6,999/mo)')),
              ],
              onChanged: (v) => onChanged(v ?? 'solo'),
            ),
          ),
        ),
      ],
    );
  }
}
