import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/consultation_audit_item.dart';

class ConsultationRegisterRow extends StatelessWidget {
  final ConsultationAuditItem item;

  const ConsultationRegisterRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border, width: 0.8)),
      ),
      child: Row(
        children: [
          // Patient Name
          Expanded(
            flex: 3,
            child: Text(
              item.patientName,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Token / Ref
          Expanded(
            flex: 2,
            child: Text(
              item.tokenNumber,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ),

          // Consulting Doctor
          Expanded(
            flex: 3,
            child: Text(
              item.doctorName,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: colors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Service Pill
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.serviceName,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Status Pill
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '🟢 ${item.status}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Consultation Fee
          Expanded(
            flex: 2,
            child: Text(
              '₹${item.consultationFee.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
