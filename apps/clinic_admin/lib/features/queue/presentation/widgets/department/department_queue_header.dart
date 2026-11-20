import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../services/domain/entities/service_department_entity.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';
import 'department_queue_metrics.dart';

class DepartmentQueueHeader extends StatelessWidget {
  final ServiceDepartmentEntity department;
  final int servicesCount;
  final List<ClinicQueueItemEntity> deptServing;
  final List<ClinicQueueItemEntity> deptWaiting;
  final bool isQueueOpen;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const DepartmentQueueHeader({
    super.key,
    required this.department,
    required this.servicesCount,
    required this.deptServing,
    required this.deptWaiting,
    required this.isQueueOpen,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onToggleCollapse,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 750;

            final leftBlock = Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    department.icon.isNotEmpty ? department.icon : '🩺',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              department.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.primaryTint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              department.code.isNotEmpty ? department.code : 'DEPT',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$servicesCount ${servicesCount == 1 ? "service" : "services"} configured',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final metrics = DepartmentQueueMetrics(
              servicesCount: servicesCount,
              deptServing: deptServing,
              deptWaiting: deptWaiting,
              isQueueOpen: isQueueOpen,
              isCollapsed: isCollapsed,
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [leftBlock, const SizedBox(height: 12), metrics],
              );
            }

            return Row(
              children: [
                Expanded(child: leftBlock),
                const SizedBox(width: 14),
                metrics,
              ],
            );
          },
        ),
      ),
    );
  }
}
