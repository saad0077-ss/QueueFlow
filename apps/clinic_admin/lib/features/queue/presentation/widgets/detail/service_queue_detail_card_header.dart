import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'service_queue_detail_tabs.dart';

class ServiceQueueDetailCardHeader extends StatelessWidget {
  final String serviceName;
  final int displayListLength;
  final String activeTab;
  final int activeCount;
  final int waitingCount;
  final int servingCount;
  final int completedSkippedCount;
  final int allCount;
  final ValueChanged<String> onTabChanged;

  const ServiceQueueDetailCardHeader({
    super.key,
    required this.serviceName,
    required this.displayListLength,
    required this.activeTab,
    required this.activeCount,
    required this.waitingCount,
    required this.servingCount,
    required this.completedSkippedCount,
    required this.allCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$serviceName Patient Queue ($displayListLength)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Live queue triage for this service · Click any row for patient actions',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
            ],
          );
          final tabs = ServiceQueueDetailTabs(
            activeTab: activeTab,
            activeCount: activeCount,
            waitingCount: waitingCount,
            servingCount: servingCount,
            completedSkippedCount: completedSkippedCount,
            allCount: allCount,
            onTabChanged: onTabChanged,
          );
          if (constraints.maxWidth < 980) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 14), tabs],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: title),
              const SizedBox(width: 16),
              Flexible(child: tabs),
            ],
          );
        },
      ),
    );
  }
}
