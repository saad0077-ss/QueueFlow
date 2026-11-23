import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';
import 'table/queue_table_desktop_view.dart';
import 'table/queue_table_empty_state.dart';
import 'table/queue_table_header.dart';
import 'table/queue_table_mobile_view.dart';

class QueueTableCard extends StatelessWidget {
  final List<ClinicQueueItemEntity> items;
  final ValueChanged<ClinicQueueItemEntity> onSelectPatient;
  final VoidCallback onCallNext;
  final VoidCallback onAddWalkIn;
  final String? breakEndsAt;

  const QueueTableCard({
    super.key,
    this.breakEndsAt,
    required this.items,
    required this.onSelectPatient,
    required this.onCallNext,
    required this.onAddWalkIn,
  });

  static bool _isToday(DateTime t) {
    final n = DateTime.now();
    final l = t.toLocal();
    return l.year == n.year && l.month == n.month && l.day == n.day;
  }

  ({String label, IconData icon, bool enabled}) get _action {
    if (breakEndsAt != null) {
      return (
        label: 'On Break · resumes $breakEndsAt',
        icon: Icons.free_breakfast_outlined,
        enabled: false,
      );
    }
    final hasCalled = items.any((i) => i.isCalled);
    final hasWaiting = items.any((i) => i.isWaiting);
    final doneToday = items.any((i) => i.isCompleted && _isToday(i.joinedAt));

    if (hasCalled) {
      return hasWaiting
          ? (
              label: 'Call Next',
              icon: Icons.arrow_forward_rounded,
              enabled: true,
            )
          : (
              label: 'Complete & Close Queue',
              icon: Icons.done_all_rounded,
              enabled: true,
            );
    }
    if (hasWaiting) {
      return doneToday
          ? (
              label: 'Call Next',
              icon: Icons.arrow_forward_rounded,
              enabled: true,
            )
          : (
              label: 'Start Consulting',
              icon: Icons.play_arrow_rounded,
              enabled: true,
            );
    }
    return doneToday
        ? (
            label: 'Queue Closed',
            icon: Icons.lock_outline_rounded,
            enabled: false,
          )
        : (
            label: 'Start Consulting',
            icon: Icons.play_arrow_rounded,
            enabled: false,
          );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final action = _action;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QueueTableHeader(
            actionLabel: action.label,
            actionIcon: action.icon,
            actionEnabled: action.enabled,
            onCallNext: onCallNext,
          ),
          Divider(height: 1, color: colors.border),
          if (items.isEmpty)
            QueueTableEmptyState(onAddWalkIn: onAddWalkIn)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 720) {
                  return QueueTableMobileView(
                    items: items,
                    onSelectPatient: onSelectPatient,
                  );
                }
                return QueueTableDesktopView(
                  items: items,
                  onSelectPatient: onSelectPatient,
                );
              },
            ),
        ],
      ),
    );
  }
}
