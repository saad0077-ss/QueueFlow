import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClinicInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final String? helperText;
  final bool isValid;
  final String? validText;
  final VoidCallback? onToggleObscure;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  const ClinicInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.helperText,
    this.isValid = false,
    this.validText,
    this.onToggleObscure,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF10B981);
    final showValid = isValid && errorText == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE2E8F0),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0B132B).withValues(alpha: 0.7),
            hintText: hintText,
            hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13.5),
            errorText: errorText,
            errorStyle: GoogleFonts.inter(color: const Color(0xFFEF4444), fontSize: 11.5),
            prefixIcon: Icon(prefixIcon, color: showValid ? green : const Color(0xFF64748B), size: 18),
            suffixIcon: onToggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF64748B),
                      size: 18,
                    ),
                    onPressed: onToggleObscure,
                  )
                : (showValid ? const Icon(Icons.check_circle_rounded, color: green, size: 19) : null),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: showValid ? green : const Color(0xFF1E293B), width: showValid ? 1.5 : 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: showValid ? green : const Color(0xFF2563EB), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.3),
            ),
          ),
        ),
        if (showValid && validText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check_rounded, color: green, size: 13),
              const SizedBox(width: 4),
              Text(validText!, style: GoogleFonts.inter(color: green, fontSize: 11.5, fontWeight: FontWeight.w500)),
            ],
          ),
        ] else if (errorText == null && helperText != null) ...[
          const SizedBox(height: 6),
          Text(helperText!, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.5)),
        ],
      ],
    );
  }
}
