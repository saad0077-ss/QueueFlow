import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final bool isValid;
  final String? validText;
  final Widget? suffixIcon;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  const AdminInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.isValid = false,
    this.validText,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF10B981);
    final showValid = isValid && errorText == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
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
            fillColor: const Color(0xFF0B132B).withValues(alpha: 0.6),
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF475569),
              fontSize: 14,
            ),
            errorText: errorText,
            errorStyle: GoogleFonts.inter(
              color: const Color(0xFFEF4444),
              fontSize: 12,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: showValid ? greenColor : const Color(0xFF64748B),
              size: 19,
            ),
            suffixIcon: suffixIcon ??
                (showValid
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: greenColor,
                        size: 20,
                      )
                    : null),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: showValid ? greenColor : const Color(0xFF1E293B),
                width: showValid ? 1.5 : 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: showValid ? greenColor : const Color(0xFF1E293B),
                width: showValid ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: showValid ? greenColor : const Color(0xFF06B6D4),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
        if (showValid && validText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.check_rounded,
                color: greenColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                validText!,
                style: GoogleFonts.inter(
                  color: greenColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
