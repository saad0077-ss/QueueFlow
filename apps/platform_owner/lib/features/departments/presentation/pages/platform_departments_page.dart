import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dashboard/presentation/pages/platform_clinics_page.dart';
import '../../../dashboard/presentation/widgets/console_sidebar.dart';
import '../../../dashboard/presentation/widgets/console_top_bar.dart';
import '../../data/repositories/department_repository_impl.dart';
import '../../domain/entities/department_entity.dart';
import '../bloc/departments_bloc.dart';
import '../bloc/departments_event.dart';
import '../widgets/dept_content_view.dart';
import 'department_details_page.dart';

class PlatformDepartmentsPage extends StatelessWidget {
  const PlatformDepartmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => DepartmentsBloc(), child: const _PlatformDepartmentsView());
  }
}

class _PlatformDepartmentsView extends StatefulWidget {
  const _PlatformDepartmentsView();

  @override
  State<_PlatformDepartmentsView> createState() => _PlatformDepartmentsViewState();
}

class _PlatformDepartmentsViewState extends State<_PlatformDepartmentsView> {
  final _repo = DepartmentRepositoryImpl();
  DepartmentEntity? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _repo.seedDepartmentsIfEmpty();
    _repo.purgeSampleRequests();
  }

  void _onSidebarNav(int index) {
    if (index == 0) {
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, _, _) => const PlatformClinicsPage(), transitionDuration: Duration.zero));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      drawer: isDesktop ? null : Drawer(child: ConsoleSidebar(activeIndex: 1, onIndexChanged: _onSidebarNav)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDesktop) ConsoleSidebar(activeIndex: 1, onIndexChanged: _onSidebarNav),
          Expanded(
            child: Builder(
              builder: (ctx) {
                if (_selectedDepartment != null) {
                  return DepartmentDetailsPage(department: _selectedDepartment!, repository: _repo, onBack: () => setState(() => _selectedDepartment = null));
                }

                return Column(
                  children: [
                    ConsoleTopBar(
                      onMenuPressed: isDesktop ? null : () => Scaffold.of(ctx).openDrawer(),
                      onSearch: (q) => ctx.read<DepartmentsBloc>().add(DepartmentSearchQueryChanged(q)),
                    ),
                    Expanded(
                      child: _StreamListener(
                        repo: _repo,
                        child: DeptContentView(repository: _repo, onDetails: (d) => setState(() => _selectedDepartment = d)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamListener extends StatelessWidget {
  final DepartmentRepositoryImpl repo;
  final Widget child;

  const _StreamListener({required this.repo, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DepartmentEntity>>(
      stream: repo.watchDepartments(),
      builder: (context, dSnap) {
        if (dSnap.hasData && dSnap.data != null) {
          context.read<DepartmentsBloc>().add(DepartmentsListUpdated(dSnap.data!));
        }
        return StreamBuilder(
          stream: repo.watchExpansionRequests(),
          builder: (context, eSnap) {
            if (eSnap.hasData && eSnap.data != null) {
              context.read<DepartmentsBloc>().add(ExpansionRequestsUpdated(eSnap.data!));
            }
            return StreamBuilder(
              stream: repo.watchServiceRequests(),
              builder: (context, sSnap) {
                if (sSnap.hasData && sSnap.data != null) {
                  context.read<DepartmentsBloc>().add(ServiceRequestsUpdated(sSnap.data!));
                }
                return child;
              },
            );
          },
        );
      },
    );
  }
}
