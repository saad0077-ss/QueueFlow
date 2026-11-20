import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../bloc/queue_filter_cubit.dart';
import 'filter/queue_filter_body.dart';
import 'filter/queue_filter_footer.dart';
import 'filter/queue_filter_modal_header.dart';

class QueueFilterModal extends StatelessWidget {
  final List<ServiceDepartmentEntity> departments;
  final String currentDepartment;
  final String currentStatus;
  final String currentSort;
  final Function({
    required String department,
    required String status,
    required String sort,
  }) onApply;
  final VoidCallback onReset;
  final Map<String, String> deptSubtitles;

  const QueueFilterModal({
    super.key,
    required this.departments,
    required this.currentDepartment,
    required this.currentStatus,
    required this.currentSort,
    required this.onApply,
    required this.onReset,
    this.deptSubtitles = const {},
  });

  static Future<void> show(
    BuildContext context, {
    required List<ServiceDepartmentEntity> departments,
    required String currentDepartment,
    required String currentStatus,
    required String currentSort,
    required Function({
      required String department,
      required String status,
      required String sort,
    }) onApply,
    required VoidCallback onReset,
    Map<String, String> deptSubtitles = const {},
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: QueueFilterModal(
            departments: departments,
            currentDepartment: currentDepartment,
            currentStatus: currentStatus,
            currentSort: currentSort,
            onApply: onApply,
            onReset: onReset,
            deptSubtitles: deptSubtitles,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QueueFilterCubit(
        initialDepartment: currentDepartment,
        initialStatus: currentStatus,
        initialSort: currentSort,
      ),
      child: _QueueFilterModalContent(
        departments: departments,
        deptSubtitles: deptSubtitles,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }
}

class _QueueFilterModalContent extends StatelessWidget {
  final List<ServiceDepartmentEntity> departments;
  final Map<String, String> deptSubtitles;
  final Function({
    required String department,
    required String status,
    required String sort,
  }) onApply;
  final VoidCallback onReset;

  const _QueueFilterModalContent({
    required this.departments,
    required this.deptSubtitles,
    required this.onApply,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: BlocBuilder<QueueFilterCubit, QueueFilterState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const QueueFilterModalHeader(),
              Flexible(
                child: QueueFilterBody(
                  departments: departments,
                  deptSubtitles: deptSubtitles,
                ),
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              QueueFilterFooter(
                onReset: () {
                  onReset();
                  Navigator.of(context).pop();
                },
                onCancel: () => Navigator.of(context).pop(),
                onApply: () {
                  onApply(
                    department: state.department,
                    status: state.status,
                    sort: state.sort,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
