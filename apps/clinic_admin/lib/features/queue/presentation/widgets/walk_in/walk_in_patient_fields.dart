import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class WalkInPatientFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController noteController;

  const WalkInPatientFields({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.noteController,
  });

  InputDecoration _decoration(BuildContext context, String hint) {
    final colors = context.colors;
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
      filled: true,
      fillColor: colors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
    );
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldStyle = GoogleFonts.inter(
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: context.colors.textPrimary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context, 'Patient Full Name *'),
        TextFormField(
          controller: nameController,
          style: fieldStyle,
          decoration: _decoration(context, 'e.g. Ramesh Kumar'),
          validator: (v) => v == null || v.trim().isEmpty
              ? 'Please enter patient name'
              : null,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, c) {
            final phone = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(context, 'Contact Phone *'),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: fieldStyle,
                  decoration: _decoration(context, '+91 98450 12345'),
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    return digits.length < 10
                        ? 'Enter a valid phone number'
                        : null;
                  },
                ),
              ],
            );
            final email = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(context, 'Email Address (Optional)'),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: fieldStyle,
                  decoration: _decoration(context, 'patient@email.com'),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return null;
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
                        ? null
                        : 'Enter a valid email';
                  },
                ),
              ],
            );
            if (c.maxWidth < 380) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [phone, const SizedBox(height: 14), email],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: phone),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: email),
              ],
            );
          },
        ),
      ],
    );
  }
}
