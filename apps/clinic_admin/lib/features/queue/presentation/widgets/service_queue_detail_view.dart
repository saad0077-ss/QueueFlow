import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';
import 'detail/service_queue_detail_breadcrumb.dart';
import 'detail/service_queue_detail_card_header.dart';
import 'detail/service_queue_detail_hero.dart';
import 'detail/service_queue_detail_kpi_row.dart';
import 'detail/service_queue_detail_table.dart';
import 'detail/service_queue_display_list_resolver.dart';
import 'detail/service_queue_empty_state.dart';

class ServiceQueueDetailView extends StatelessWidget {
  final ClinicServiceEntity service;
  final ServiceDepartmentEntity? department;
  final List<ClinicQueueItemEntity> allQueueItems;
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  final VoidCallback onBack;
  final VoidCallback onCallNext;
  final VoidCallback onAddWalkIn;
  final bool isClosed;
  final VoidCallback onToggleClosed;
  final ValueChanged<ClinicQueueItemEntity> onSelectPatient;
  final ValueChanged<String> onCallSpecific;
  final ValueChanged<String> onComplete;
  final ValueChanged<String> onSkip;

  const ServiceQueueDetailView({
    super.key,
    required this.service,
    this.department,
    required this.allQueueItems,
    required this.activeTab,
    required this.onTabChanged,
    required this.onBack,
    required this.onCallNext,
    required this.onAddWalkIn,
    required this.isClosed,
    required this.onToggleClosed,
    required this.onSelectPatient,
    required this.onCallSpecific,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sQueue = allQueueItems.where((q) {
      return q.serviceName.trim().toLowerCase() ==
          service.name.trim().toLowerCase();
    }).toList();

    final sServing = sQueue.where((q) => q.isCalled).firstOrNull;
    final sWaiting = sQueue.where((q) => q.isWaiting).toList();
    final sCompleted = sQueue.where((q) => q.isCompleted).toList();
    final sSkipped = sQueue.where((q) => q.isSkipped).toList();
    final estWaitMin = sWaiting.isNotEmpty
        ? (sWaiting.length * (service.duration > 0 ? service.duration : 15))
        : 0;

    final displayList = ServiceQueueDisplayListResolver.resolve(
      activeTab: activeTab,
      sQueue: sQueue,
      sWaiting: sWaiting,
      sServing: sServing,
      sCompleted: sCompleted,
      sSkipped: sSkipped,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ServiceQueueDetailBreadcrumb(
          service: service,
          department: department,
          onBack: onBack,
        ),
        const SizedBox(height: 18),
        ServiceQueueDetailHero(
          service: service,
          department: department,
          hasWaiting: sWaiting.isNotEmpty,
          isClosed: isClosed,
          onCallNext: onCallNext,
          onAddWalkIn: onAddWalkIn,
          onToggleClosed: onToggleClosed,
        ),
        const SizedBox(height: 18),
        ServiceQueueDetailKpiRow(
          servingItem: sServing,
          waitingCount: sWaiting.length,
          estWaitMinutes: estWaitMin,
          completedCount: sCompleted.length,
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
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
              ServiceQueueDetailCardHeader(
                serviceName: service.name,
                displayListLength: displayList.length,
                activeTab: activeTab,
                activeCount: (sServing != null ? 1 : 0) + sWaiting.length,
                waitingCount: sWaiting.length,
                servingCount: sServing != null ? 1 : 0,
                completedSkippedCount: sCompleted.length + sSkipped.length,
                allCount: sQueue.length,
                onTabChanged: onTabChanged,
              ),
              Divider(height: 1, color: colors.border),
              if (displayList.isEmpty)
                ServiceQueueEmptyState(
                  activeTab: activeTab,
                  serviceName: service.name,
                  onAddWalkIn: onAddWalkIn,
                )
              else
                ServiceQueueDetailTable(
                  items: displayList,
                  sWaiting: sWaiting,
                  onSelectPatient: onSelectPatient,
                  onCallSpecific: onCallSpecific,
                  onComplete: onComplete,
                  onSkip: onSkip,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
