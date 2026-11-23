import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../services/domain/entities/clinic_service_entity.dart';
import '../../../../services/domain/entities/service_department_entity.dart';
import 'service_queue_close_dialog.dart';
import 'service_queue_detail_hero_actions.dart';
import 'service_queue_detail_hero_info.dart';

class ServiceQueueDetailHero extends StatelessWidget {
  final ClinicServiceEntity service;
  final ServiceDepartmentEntity? department;
  final bool hasWaiting;
  final bool isClosed;
  final VoidCallback onCallNext;
  final VoidCallback onAddWalkIn;
  final VoidCallback onToggleClosed;

  const ServiceQueueDetailHero({
    super.key,
    required this.service,
    this.department,
    required this.hasWaiting,
    required this.isClosed,
    required this.onCallNext,
    required this.onAddWalkIn,
    required this.onToggleClosed,
  });

  Future<void> _handleToggleClosed(BuildContext context) async {
    if (isClosed) {
      onToggleClosed();
      return;
    }
    final ok = await ServiceQueueCloseDialog.show(context, service.name);
    if (ok == true) onToggleClosed();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 750;
          final infoBlock = ServiceQueueDetailHeroInfo(
            service: service,
            department: department,
          );
          final actions = ServiceQueueDetailHeroActions(
            hasWaiting: hasWaiting,
            isClosed: isClosed,
            onCallNext: onCallNext,
            onAddWalkIn: onAddWalkIn,
            onToggleClosed: () => _handleToggleClosed(context),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [infoBlock, const SizedBox(height: 16), actions],
            );
          }
          return Row(
            children: [
              Expanded(child: infoBlock),
              const SizedBox(width: 16),
              actions,
            ],
          );
        },
      ),
    );
  }
}
