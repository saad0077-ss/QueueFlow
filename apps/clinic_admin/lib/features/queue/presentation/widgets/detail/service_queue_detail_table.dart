import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';
import 'service_queue_detail_row.dart';

class ServiceQueueDetailTable extends StatelessWidget {
  final List<ClinicQueueItemEntity> items;
  final List<ClinicQueueItemEntity> sWaiting;
  final ValueChanged<ClinicQueueItemEntity> onSelectPatient;
  final ValueChanged<String> onCallSpecific;
  final ValueChanged<String> onComplete;
  final ValueChanged<String> onSkip;

  const ServiceQueueDetailTable({
    super.key,
    required this.items,
    required this.sWaiting,
    required this.onSelectPatient,
    required this.onCallSpecific,
    required this.onComplete,
    required this.onSkip,
  });

  Widget _head(BuildContext context, String t, {TextAlign align = TextAlign.left}) =>
      Text(
        t,
        textAlign: align,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: context.colors.textMuted,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 900 ? 900.0 : constraints.maxWidth;
        final table = SizedBox(
          width: width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    SizedBox(width: ServiceQueueDetailRow.wIndex, child: _head(context, '#')),
                    Expanded(flex: 12, child: _head(context, 'TOKEN')),
                    Expanded(flex: 30, child: _head(context, 'PATIENT NAME & CONTACT')),
                    Expanded(flex: 14, child: _head(context, 'JOINED TIME')),
                    Expanded(flex: 13, child: _head(context, 'EST. DURATION')),
                    Expanded(flex: 17, child: _head(context, 'QUEUE STATUS')),
                    SizedBox(
                      width: ServiceQueueDetailRow.wActions,
                      child: _head(context, 'TRIAGE ACTIONS', align: TextAlign.right),
                    ),
                  ],
                ),
              ),
              for (final item in items) ...[
                Divider(height: 1, color: colors.border),
                ServiceQueueDetailRow(
                  item: item,
                  sWaiting: sWaiting,
                  onSelectPatient: onSelectPatient,
                  onCallSpecific: onCallSpecific,
                  onComplete: onComplete,
                  onSkip: onSkip,
                ),
              ],
            ],
          ),
        );
        if (constraints.maxWidth >= 900) return table;
        return SingleChildScrollView(scrollDirection: Axis.horizontal, child: table);
      },
    );
  }
}
