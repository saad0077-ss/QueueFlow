import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';
import 'queue_table_status_badge.dart';

class QueueTableDesktopView extends StatelessWidget {
  final List<ClinicQueueItemEntity> items;
  final ValueChanged<ClinicQueueItemEntity> onSelectPatient;

  const QueueTableDesktopView({
    super.key,
    required this.items,
    required this.onSelectPatient,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: box.maxWidth),
          child: DataTable(
            showCheckboxColumn: false,
            headingRowHeight: 44,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 56,
            horizontalMargin: 20,
            columnSpacing: 40,
            dividerThickness: 1,
            border: TableBorder(
              horizontalInside: BorderSide(color: colors.border),
            ),
            headingRowColor: const WidgetStatePropertyAll(Colors.transparent),
            headingTextStyle: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: colors.textMuted,
            ),
            columns: const [
              DataColumn(label: Text('TOKEN')),
              DataColumn(label: Text('PATIENT NAME')),
              DataColumn(label: Text('SERVICE')),
              DataColumn(label: Text('JOINED')),
              DataColumn(label: Text('EST. DURATION')),
              DataColumn(label: Text('STATUS')),
            ],
            rows: items.map((item) {
              final isCalled = item.isCalled;

              return DataRow(
                onSelectChanged: (_) => onSelectPatient(item),
                color: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return colors.primaryTint.withValues(alpha: 0.45);
                  }
                  if (isCalled) {
                    return colors.primaryTint.withValues(alpha: 0.35);
                  }
                  return Colors.transparent;
                }),
                cells: [
                  DataCell(
                    Text(
                      item.token,
                      style: GoogleFonts.robotoMono(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      item.patientName,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      item.serviceName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      item.joinedTime,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      item.estDuration,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                  DataCell(QueueTableStatusBadge(status: item.status)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
