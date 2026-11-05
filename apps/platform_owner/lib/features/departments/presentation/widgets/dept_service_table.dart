import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/dept_service_request_entity.dart';

class DeptServiceTable extends StatelessWidget {
  final List<DeptServiceRequestEntity> requests;
  final ValueChanged<DeptServiceRequestEntity> onApprove;
  final ValueChanged<DeptServiceRequestEntity> onReject;

  const DeptServiceTable({super.key, required this.requests, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('🔬', style: TextStyle(fontSize: 16)),
            Text(
              'Custom Procedure & Service Requests',
              style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: colors.textPrimary),
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
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth = constraints.maxWidth < 960 ? 960.0 : constraints.maxWidth;
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(children: [_buildHeader(context), ...requests.map((r) => _buildRow(context, r))]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Clinic & Doctor',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.textMuted),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Proposed Service',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.textMuted),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Department',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.textMuted),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Duration / Fee',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.textMuted),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Clinical Justification',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.textMuted),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Actions',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, DeptServiceRequestEntity r) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.clinicName,
                  style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                Text('By: ${r.requestedBy}', style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.serviceName,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: colors.primary),
                ),
                Text(
                  r.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                child: Text(
                  r.departmentName,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.primary),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⏱️ ${r.duration} mins', style: GoogleFonts.inter(fontSize: 11.5, color: colors.textPrimary)),
                Text(
                  '₹${r.suggestedPrice}',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.border),
              ),
              child: Text('💬 "${r.notes}"', style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => onApprove(r),
                  child: const Text('✓ Approve & Catalog', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 4),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error),
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
