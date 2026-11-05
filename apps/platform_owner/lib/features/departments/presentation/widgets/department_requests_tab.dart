import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'accent_border_card.dart';

import '../../domain/entities/dept_service_request_entity.dart';
import 'dept_service_req_card.dart';

class DepartmentRequestsTab extends StatelessWidget {
  final List<DeptServiceRequestEntity> requests;
  final ValueChanged<DeptServiceRequestEntity> onApprove;
  final ValueChanged<DeptServiceRequestEntity> onReject;

  const DepartmentRequestsTab({super.key, required this.requests, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccentBorderCard(
          accent: const Color(0xFFF59E0B),
          radius: 12,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('📩', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Specialty Approval Queue for this Department',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'When clinic practitioners request a procedure not yet in this catalog, it appears here for review.',
                      style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (requests.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Text('No pending service requests for this department.', style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted)),
          )
        else
          ...requests.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DeptServiceReqCard(request: r, onApprove: onApprove, onReject: onReject),
            ),
          ),
      ],
    );
  }
}
