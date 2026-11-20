import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';
import 'department/department_queue_header.dart';
import 'department/department_queue_services_grid.dart';

class DepartmentQueueCard extends StatelessWidget {
  final ServiceDepartmentEntity department;
  final List<ClinicServiceEntity> services;
  final List<ClinicQueueItemEntity> queueItems;
  final bool isCollapsed;
  final bool isQueueOpen;
  final VoidCallback onToggleCollapse;
  final ValueChanged<ClinicServiceEntity> onOpenServiceQueue;
  final ValueChanged<ClinicServiceEntity> onCallNextService;

  const DepartmentQueueCard({
    super.key,
    required this.department,
    required this.services,
    required this.queueItems,
    required this.isCollapsed,
    required this.isQueueOpen,
    required this.onToggleCollapse,
    required this.onOpenServiceQueue,
    required this.onCallNextService,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final deptItems = queueItems.where((q) {
      return services.any(
        (s) => s.name.trim().toLowerCase() == q.serviceName.trim().toLowerCase(),
      );
    }).toList();

    final deptWaiting = deptItems.where((q) => q.isWaiting).toList();
    final deptServing = deptItems.where((q) => q.isCalled).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DepartmentQueueHeader(
            department: department,
            servicesCount: services.length,
            deptServing: deptServing,
            deptWaiting: deptWaiting,
            isQueueOpen: isQueueOpen,
            isCollapsed: isCollapsed,
            onToggleCollapse: onToggleCollapse,
          ),
          if (!isCollapsed) ...[
            Divider(height: 1, color: colors.border),
            Padding(
              padding: const EdgeInsets.all(20),
              child: DepartmentQueueServicesGrid(
                services: services,
                queueItems: queueItems,
                isQueueOpen: isQueueOpen,
                onOpenServiceQueue: onOpenServiceQueue,
                onCallNextService: onCallNextService,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
