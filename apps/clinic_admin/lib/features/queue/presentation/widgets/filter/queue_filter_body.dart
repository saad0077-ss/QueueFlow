import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../services/domain/entities/service_department_entity.dart';
import '../../bloc/queue_filter_bloc.dart';
import 'queue_filter_dept_grid.dart';
import 'queue_filter_sort_section.dart';
import 'queue_filter_status_grid.dart';

class QueueFilterBody extends StatelessWidget {
  final List<ServiceDepartmentEntity> departments;
  final Map<String, String> deptSubtitles;

  const QueueFilterBody({
    super.key,
    required this.departments,
    required this.deptSubtitles,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueFilterBloc, QueueFilterState>(
      builder: (context, state) {
        final bloc = context.read<QueueFilterBloc>();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppFilterSectionTitle('HEALTHCARE DEPARTMENT'),
              const SizedBox(height: 10),
              QueueFilterDeptGrid(
                departments: departments,
                selectedDept: state.department,
                deptSubtitles: deptSubtitles,
                onSelectDept: bloc.setDepartment,
              ),
              const SizedBox(height: 20),
              const AppFilterSectionTitle('QUEUE LOAD & STATUS'),
              const SizedBox(height: 10),
              QueueFilterStatusGrid(
                selectedStatus: state.status,
                onSelectStatus: bloc.setStatus,
              ),
              const SizedBox(height: 20),
              const AppFilterSectionTitle('SORT ORDER'),
              const SizedBox(height: 10),
              QueueFilterSortSection(
                currentSort: state.sort,
                onSortChanged: bloc.setSort,
              ),
            ],
          ),
        );
      },
    );
  }
}
