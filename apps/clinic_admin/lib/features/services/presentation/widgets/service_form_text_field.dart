import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_ui_kit.dart';

class ServiceFormTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? hint;
  final String? errorText;
  final bool numeric;

  const ServiceFormTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.hint,
    this.errorText,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return ServiceLabeledField(
      label: label,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: numeric ? TextInputType.number : null,
        inputFormatters: numeric
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        cursorColor: ServiceColors.focus,
        style: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        decoration: serviceInputDecoration(hint: hint, errorText: errorText),
      ),
    );
  }
}
