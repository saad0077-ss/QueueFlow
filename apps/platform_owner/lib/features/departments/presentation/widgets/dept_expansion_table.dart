import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/dept_expansion_request_entity.dart';

class DeptExpansionTable extends StatelessWidget {
  final List<DeptExpansionRequestEntity> requests;
  final ValueChanged<DeptExpansionRequestEntity> onApprove;
  final ValueChanged<DeptExpansionRequestEntity> onReject;

  const DeptExpansionTable({super.key, required this.requests, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 6,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('🏥', style: TextStyle(fontSize: 16)),
                Text(
                  'Clinic Multi-Department Expansion Requests',
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    '${requests.length} Pending',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                  ),
                ),
              ],
            ),
            Text('Approving activates the specialties & provisions service catalogs', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth = constraints.maxWidth < 960 ? 960.0 : constraints.maxWidth;
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF070B14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(children: [_buildHeader(), ...requests.map((r) => _buildRow(r))]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1324),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'Clinic & Requester',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Specialties Requested',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Staffing & Target',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Clinical Justification',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Super Admin Action',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(DeptExpansionRequestEntity r) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.clinicName,
                  style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text('By: ${r.requestedBy} • ${r.createdAt}', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                Text('ID: ${r.id}', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF38BDF8))),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(r.departmentNames.length, (i) {
                final icon = i < r.departmentIcons.length ? r.departmentIcons[i] : '🩺';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '$icon ${r.departmentNames[i]}',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF38BDF8)),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👨‍⚕️ ${r.expectedDoctorCount} Specialist(s)',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                Text('Target: ${r.targetDate}', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Text('💬 "${r.reason}"', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFCBD5E1))),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => onApprove(r),
                  child: const Text('✓ Approve & Activate', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 4),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => onReject(r),
                  child: const Text('✕ Reject', style: TextStyle(fontSize: 10.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
