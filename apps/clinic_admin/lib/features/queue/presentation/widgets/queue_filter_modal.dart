import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../services/domain/entities/service_department_entity.dart';
import '../bloc/queue_filter_bloc.dart';
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
  })
  onApply;
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
    })
    onApply,
    required VoidCallback onReset,
    Map<String, String> deptSubtitles = const {},
  }) {
    return AppFilterDialogScaffold.show(
      context,
      builder: (context) => QueueFilterModal(
        departments: departments,
        currentDepartment: currentDepartment,
        currentStatus: currentStatus,
        currentSort: currentSort,
        onApply: onApply,
        onReset: onReset,
        deptSubtitles: deptSubtitles,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QueueFilterBloc(
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
  })
  onApply;
  final VoidCallback onReset;

  const _QueueFilterModalContent({
    required this.departments,
    required this.deptSubtitles,
    required this.onApply,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueFilterBloc, QueueFilterState>(
      builder: (context, state) {
        return AppFilterDialogScaffold(
          header: const QueueFilterModalHeader(),
          body: QueueFilterBody(
            departments: departments,
            deptSubtitles: deptSubtitles,
          ),
          footer: QueueFilterFooter(
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
        );
      },
    );
  }
}
