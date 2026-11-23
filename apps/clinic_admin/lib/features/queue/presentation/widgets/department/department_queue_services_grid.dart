import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../services/domain/entities/clinic_service_entity.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';
import '../service_queue_card.dart';

class DepartmentQueueServicesGrid extends StatelessWidget {
  final List<ClinicServiceEntity> services;
  final List<ClinicQueueItemEntity> queueItems;
  final bool isQueueOpen;
  final ValueChanged<ClinicServiceEntity> onOpenServiceQueue;
  final ValueChanged<ClinicServiceEntity> onCallNextService;

  const DepartmentQueueServicesGrid({
    super.key,
    required this.services,
    required this.queueItems,
    required this.isQueueOpen,
    required this.onOpenServiceQueue,
    required this.onCallNextService,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No services configured in this department.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: context.colors.textMuted,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = ((constraints.maxWidth + 16) / (340 + 16))
            .floor()
            .clamp(1, 6);
        final itemWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * 16)) /
            crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: services.map((svc) {
            final sQueue = queueItems.where((q) {
              return q.serviceName.trim().toLowerCase() ==
                  svc.name.trim().toLowerCase();
            }).toList();

            return SizedBox(
              width: itemWidth,
              child: ServiceQueueCard(
                service: svc,
                queueItems: sQueue,
                isQueueOpen: isQueueOpen,
                onViewQueue: () => onOpenServiceQueue(svc),
                onCallNext: () => onCallNextService(svc),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
