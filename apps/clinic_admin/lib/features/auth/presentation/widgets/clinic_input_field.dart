import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

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
    final colors = context.colors;
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
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surfaceSecondary,
            hintText: hintText,
            hintStyle: GoogleFonts.inter(color: colors.textMuted, fontSize: 13.5),
            errorText: errorText,
            errorStyle: GoogleFonts.inter(color: colors.error, fontSize: 11.5),
            prefixIcon: Icon(
              prefixIcon,
              color: showValid ? colors.success : colors.textMuted,
              size: 18,
            ),
            suffixIcon: onToggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: colors.textMuted,
                      size: 18,
                    ),
                    onPressed: onToggleObscure,
                  )
                : (showValid ? Icon(Icons.check_circle_rounded, color: colors.success, size: 19) : null),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: showValid ? colors.success : colors.border,
                width: showValid ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: showValid ? colors.success : colors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.error, width: 1.3),
            ),
          ),
        ),
        if (showValid && validText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.check_rounded, color: colors.success, size: 13),
              const SizedBox(width: 4),
              Text(
                validText!,
                style: GoogleFonts.inter(
                  color: colors.success,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ] else if (errorText == null && helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: GoogleFonts.inter(color: colors.textSubtle, fontSize: 11.5),
          ),
        ],
      ],
    );
  }
}
