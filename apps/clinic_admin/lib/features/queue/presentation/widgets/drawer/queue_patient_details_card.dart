import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';

class QueuePatientDetailsCard extends StatelessWidget {
  final ClinicQueueItemEntity patient;

  const QueuePatientDetailsCard({super.key, required this.patient});

  Widget _dataRow(
    BuildContext context,
    String label,
    String value, {
    bool isStatus = false,
  }) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: colors.textMuted,
          ),
        ),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: patient.isCancelled
                  ? const Color(0xFFEF4444).withValues(alpha: 0.14)
                  : patient.isCalled
                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                  : const Color(0xFF0284C7).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: patient.isCancelled
                    ? const Color(0xFFEF4444)
                    : patient.isCalled
                    ? const Color(0xFF059669)
                    : const Color(0xFF0284C7),
              ),
            ),
          )
        else
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        children: [
          _dataRow(
            context,
            'Contact Phone',
            patient.phone.isEmpty ? '—' : patient.phone,
          ),
          const SizedBox(height: 10),
          _dataRow(
            context,
            'Email',
            patient.email.isEmpty ? '—' : patient.email,
          ),
          const SizedBox(height: 10),
          _dataRow(context, 'Joined At', patient.joinedTime),
          const SizedBox(height: 10),
          _dataRow(
            context,
            'Current Status',
            patient.status.toUpperCase(),
            isStatus: true,
          ),
          const SizedBox(height: 10),
          _dataRow(
            context,
            'Payment Status',
            patient.paymentStatus == 'paid'
                ? 'PAID · ₹100'
                : patient.paymentStatus.toUpperCase(),
          ),
          if (patient.note.isNotEmpty) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Triage Notes',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Text(
                patient.note,
                style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
