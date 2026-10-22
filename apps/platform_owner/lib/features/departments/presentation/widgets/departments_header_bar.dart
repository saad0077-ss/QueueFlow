import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DepartmentsHeaderBar extends StatelessWidget {
  final int activeCount;
  final VoidCallback onExportCsv;
  final VoidCallback onRefresh;
  final VoidCallback onAddDepartment;

  const DepartmentsHeaderBar({super.key, required this.activeCount, required this.onExportCsv, required this.onRefresh, required this.onAddDepartment});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 750;

        final titleCol = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'SPECIALTY MANAGEMENT',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '$activeCount Active Specialties',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Platform Medical Departments',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              'Global clinical specialty catalog, multi-clinic department allocation, consultation rules and triage',
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
            ),
          ],
        );

        final actionRow = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _secondaryBtn('📥 Export CSV', onExportCsv),
            _secondaryBtn('🔄 Refresh', onRefresh),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: onAddDepartment,
              child: Text('+ Add Department', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        );

        if (isCompact) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [titleCol, const SizedBox(height: 16), actionRow]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleCol),
            const SizedBox(width: 16),
            actionRow,
          ],
        );
      },
    );
  }

  Widget _secondaryBtn(String label, VoidCallback onPressed) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF0D1526),
        foregroundColor: const Color(0xFFE2E8F0),
        side: const BorderSide(color: Color(0xFF1E293B)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(label, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500)),
    );
  }
}
