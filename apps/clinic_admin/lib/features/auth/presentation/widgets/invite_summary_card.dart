import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class InviteSummaryCard extends StatelessWidget {
  final String email;
  final String role;
  final String clinicName;

  const InviteSummaryCard({
    super.key,
    required this.email,
    required this.role,
    required this.clinicName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildRow('Email', email, colors),
          Divider(color: colors.border, height: 20, thickness: 1),
          _buildRow('Role', role, colors),
          Divider(color: colors.border, height: 20, thickness: 1),
          _buildRow('Clinic', clinicName, colors),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, AppColorsExtension colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: colors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
