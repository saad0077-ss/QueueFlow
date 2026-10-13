import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          _buildRow('Email', email),
          const Divider(color: Color(0xFF1E293B), height: 20, thickness: 1),
          _buildRow('Role', role),
          const Divider(color: Color(0xFF1E293B), height: 20, thickness: 1),
          _buildRow('Clinic', clinicName),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
