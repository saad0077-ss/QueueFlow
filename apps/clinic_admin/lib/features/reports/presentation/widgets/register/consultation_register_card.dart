import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/consultation_audit_item.dart';
import 'consultation_register_table.dart';

class ConsultationRegisterCard extends StatelessWidget {
  final List<ConsultationAuditItem> consultations;

  const ConsultationRegisterCard({
    super.key,
    required this.consultations,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Patient Consultations Register',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Audit log of recently completed patient visits and consultation fees',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '🟢 LIVE AUDIT',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Register Table
          ConsultationRegisterTable(items: consultations),
        ],
      ),
    );
  }
}
