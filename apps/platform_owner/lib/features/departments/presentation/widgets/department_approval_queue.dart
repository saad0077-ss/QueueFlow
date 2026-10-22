import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'accent_border_card.dart';

import '../../domain/entities/dept_expansion_request_entity.dart';
import '../../domain/entities/dept_service_request_entity.dart';
import 'dept_expansion_table.dart';
import 'dept_service_table.dart';

class DepartmentApprovalQueue extends StatelessWidget {
  final List<DeptExpansionRequestEntity> expansionRequests;
  final List<DeptServiceRequestEntity> serviceRequests;
  final ValueChanged<DeptExpansionRequestEntity> onApproveExpansion;
  final ValueChanged<DeptExpansionRequestEntity> onRejectExpansion;
  final ValueChanged<DeptServiceRequestEntity> onApproveService;
  final ValueChanged<DeptServiceRequestEntity> onRejectService;

  const DepartmentApprovalQueue({
    super.key,
    required this.expansionRequests,
    required this.serviceRequests,
    required this.onApproveExpansion,
    required this.onRejectExpansion,
    required this.onApproveService,
    required this.onRejectService,
  });

  @override
  Widget build(BuildContext context) {
    final total = expansionRequests.length + serviceRequests.length;

    return AccentBorderCard(
      accent: const Color(0xFFF59E0B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: const Text('📩', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
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
                          'Clinic Service & Specialty Approval Requests',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: (total > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$total PENDING',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: total > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Clinics requesting new treatments/procedures. Once approved, the service is activated for the clinic and added to the Department's catalog.",
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.sizeOf(context).width >= 1100) ...[
                const SizedBox(width: 12),
                Text('Governed Medical Catalog Engine • Active', style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B))),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (total == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF070B14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inter(fontSize: 12.5),
                  children: [
                    TextSpan(
                      text: '✓ All clinic requests reviewed! ',
                      style: GoogleFonts.inter(color: const Color(0xFF10B981), fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'No pending multi-department expansion or custom service additions awaiting Super Admin approval.',
                      style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (expansionRequests.isNotEmpty) ...[
              DeptExpansionTable(requests: expansionRequests, onApprove: onApproveExpansion, onReject: onRejectExpansion),
              if (serviceRequests.isNotEmpty) const SizedBox(height: 16),
            ],
            if (serviceRequests.isNotEmpty) DeptServiceTable(requests: serviceRequests, onApprove: onApproveService, onReject: onRejectService),
          ],
        ],
      ),
    );
  }
}
