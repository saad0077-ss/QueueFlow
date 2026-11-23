import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/navigation/platform_navigation_helper.dart';
import '../../../dashboard/presentation/widgets/console_sidebar.dart';
import '../../../dashboard/presentation/widgets/console_top_bar.dart';
import '../../data/repositories/department_repository_impl.dart';
import '../../domain/entities/department_entity.dart';
import '../bloc/departments_bloc.dart';
import '../bloc/departments_event.dart';
import '../widgets/departments_stream_listener.dart';
import '../widgets/dept_content_view.dart';
import 'department_details_page.dart';

class PlatformDepartmentsPage extends StatefulWidget {
  const PlatformDepartmentsPage({super.key});

  @override
  State<PlatformDepartmentsPage> createState() =>
      _PlatformDepartmentsPageState();
}

class _PlatformDepartmentsPageState extends State<PlatformDepartmentsPage> {
  final _repo = DepartmentRepositoryImpl();
  DepartmentEntity? _selectedDepartment;

  void _onSidebarNav(int i) {
    PlatformNavigationHelper.navigateTo(context, i, 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return BlocProvider(
      create: (context) => DepartmentsBloc(),
      child: Scaffold(
        backgroundColor: colors.background,
        drawer: isDesktop
            ? null
            : Drawer(
                child: ConsoleSidebar(
                  activeIndex: 1,
                  onIndexChanged: _onSidebarNav,
                ),
              ),
        body: Row(
          children: [
            if (isDesktop)
              ConsoleSidebar(activeIndex: 1, onIndexChanged: _onSidebarNav),
            Expanded(
              child: Builder(
                builder: (ctx) {
                  if (_selectedDepartment != null) {
                    return DepartmentDetailsPage(
                      department: _selectedDepartment!,
                      repository: _repo,
                      onBack: () => setState(() => _selectedDepartment = null),
                    );
                  }

                  return Column(
                    children: [
                      ConsoleTopBar(
                        onMenuPressed: isDesktop
                            ? null
                            : () => Scaffold.of(ctx).openDrawer(),
                        onSearch: (q) => ctx.read<DepartmentsBloc>().add(
                          DepartmentSearchQueryChanged(q),
                        ),
                      ),
                      Expanded(
                        child: DepartmentsStreamListener(
                          repo: _repo,
                          child: DeptContentView(
                            repository: _repo,
                            onDetails: (d) =>
                                setState(() => _selectedDepartment = d),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
