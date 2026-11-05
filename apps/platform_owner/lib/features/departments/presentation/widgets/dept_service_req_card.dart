import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/dept_service_request_entity.dart';

class DeptServiceReqCard extends StatelessWidget {
  final DeptServiceRequestEntity request;
  final ValueChanged<DeptServiceRequestEntity> onApprove;
  final ValueChanged<DeptServiceRequestEntity> onReject;

  const DeptServiceReqCard({super.key, required this.request, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          request.serviceName,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            request.departmentName,
                            style: GoogleFonts.inter(fontSize: 10, color: colors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${request.clinicName} • By ${request.requestedBy} • ${request.duration}m • ₹${request.suggestedPrice}',
                      style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => onApprove(request),
                    child: const Text('✓ Catalog', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                      side: BorderSide(color: colors.error),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => onReject(request),
                    child: const Text('Reject', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
          if (request.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.border),
              ),
              child: Text('"${request.notes}"', style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted)),
            ),
          ],
        ],
      ),
    );
  }
}
