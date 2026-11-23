import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class RaiseConcernTokenCard extends StatelessWidget {
  final String? tokenNumber;
  final String clinicName;
  final bool attachToken;
  final ValueChanged<bool?> onToggleAttach;
  final AppColorsExtension colors;

  const RaiseConcernTokenCard({
    super.key,
    required this.tokenNumber,
    required this.clinicName,
    required this.attachToken,
    required this.onToggleAttach,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2563EB).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tokenNumber ?? 'A-024',
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Link with Active Token',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    '$clinicName • Active spot',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Checkbox(
            value: attachToken,
            activeColor: const Color(0xFF2563EB),
            onChanged: onToggleAttach,
          ),
        ],
      ),
    );
  }
}
