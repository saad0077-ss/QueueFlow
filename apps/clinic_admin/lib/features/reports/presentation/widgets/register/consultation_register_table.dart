import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/consultation_audit_item.dart';
import 'consultation_register_row.dart';

class ConsultationRegisterTable extends StatelessWidget {
  final List<ConsultationAuditItem> items;

  const ConsultationRegisterTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Text(
            'No consultations registered for this reporting period.',
            style: GoogleFonts.inter(color: colors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth =
            constraints.maxWidth < 680 ? 680.0 : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _headerCell('PATIENT NAME', flex: 3, colors: colors),
                      _headerCell('TOKEN / REF', flex: 2, colors: colors),
                      _headerCell('CONSULTING DOCTOR', flex: 3, colors: colors),
                      _headerCell('SERVICE', flex: 3, colors: colors),
                      _headerCell('STATUS', flex: 2, colors: colors),
                      _headerCell(
                        'CONSULTATION FEE',
                        flex: 2,
                        colors: colors,
                        align: TextAlign.right,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Table Rows
                for (final item in items) ConsultationRegisterRow(item: item),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _headerCell(
    String label, {
    required int flex,
    required AppColorsExtension colors,
    TextAlign align = TextAlign.left,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: colors.textMuted,
          letterSpacing: 0.4,
        ),
        textAlign: align,
      ),
    );
  }
}
