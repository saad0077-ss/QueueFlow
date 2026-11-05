import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/department_entity.dart';

class DepartmentDetailsHeader extends StatelessWidget {
  final DepartmentEntity department;

  const DepartmentDetailsHeader({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 900;

          final info = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text(department.icon, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          department.name,
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: colors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            department.code,
                            style: GoogleFonts.jetBrainsMono(fontSize: 11.5, fontWeight: FontWeight.w800, color: colors.primary),
                          ),
                        ),
                        _statusPill(context, department.isActive),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Text(department.description, style: GoogleFonts.inter(fontSize: 13.5, color: colors.textMuted, height: 1.45)),
                    ),
                  ],
                ),
              ),
            ],
          );

          final metrics = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metric(context, 'LICENSED CLINICS', department.assignedClinics.length.toString()),
              _metric(context, 'ACTIVE DOCTORS', department.doctorCount.toString()),
              _metric(context, 'AVG CONSULT', department.avgConsultationTime),
              _metric(context, 'MONTHLY TRIAGE', _formatNum(department.totalVisits)),
            ],
          );

          if (isNarrow) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [info, const SizedBox(height: 16), metrics]);
          }

          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 20),
              metrics,
            ],
          );
        },
      ),
    );
  }

  Widget _statusPill(BuildContext context, bool active) {
    final colors = context.colors;
    final color = active ? colors.success : colors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(
        active ? 'ACTIVE' : 'INACTIVE',
        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 15),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: colors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  String _formatNum(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
