import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/navigation/platform_navigation_helper.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import '../bloc/clinics_directory_bloc.dart';
import '../widgets/clinic_details/clinic_details_view.dart';
import '../widgets/clinic_invite_helper.dart';
import '../../../departments/data/repositories/department_repository_impl.dart';
import '../widgets/console_sidebar.dart';
import '../widgets/platform_clinics_directory_view.dart';

class PlatformClinicsPage extends StatelessWidget {
  const PlatformClinicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClinicsDirectoryBloc(),
      child: const _PlatformClinicsView(),
    );
  }
}

class _PlatformClinicsView extends StatefulWidget {
  const _PlatformClinicsView();

  @override
  State<_PlatformClinicsView> createState() => _PlatformClinicsViewState();
}

class _PlatformClinicsViewState extends State<_PlatformClinicsView> {
  final repo = TenantRepositoryImpl();
  final _departments$ = DepartmentRepositoryImpl().watchDepartments();
  late final _appointments$ = repo.watchMonthlyAppointmentCounts();
  late final _clinics$ = repo.watchClinics();
  TenantClinicEntity? _selectedClinic;

  @override
  void initState() {
    super.initState();
    repo.purgeDummyClinics();
  }

  void _onSidebarNav(int i) {
    PlatformNavigationHelper.navigateTo(context, i, 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      drawer: isDesktop
          ? null
          : Drawer(
              child: ConsoleSidebar(
                activeIndex: 0,
                onIndexChanged: _onSidebarNav,
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            ConsoleSidebar(activeIndex: 0, onIndexChanged: _onSidebarNav),
          Expanded(
            child: Builder(
              builder: (ctx) {
                final selected = _selectedClinic;
                return IndexedStack(
                  index: selected == null ? 0 : 1,
                  children: [
                    PlatformClinicsDirectoryView(
                      isDesktop: isDesktop,
                      clinicsStream: _clinics$,
                      appointmentsStream: _appointments$,
                      departmentsStream: _departments$,
                      repo: repo,
                      onDetails: (c) => setState(() => _selectedClinic = c),
                      onResendInvite: (c) => ClinicInviteHelper.resendInvite(
                        context: context,
                        repo: repo,
                        clinic: c,
                      ),
                      onClinicDeleted: () {
                        if (_selectedClinic != null) {
                          setState(() => _selectedClinic = null);
                        }
                      },
                    ),
                    if (selected != null)
                      ClinicDetailsView(
                        key: ValueKey(selected.id),
                        clinic: selected,
                        repo: repo,
                        onBack: () => setState(() => _selectedClinic = null),
                        onOpenDrawer: isDesktop
                            ? null
                            : () => Scaffold.of(ctx).openDrawer(),
                      )
                    else
                      const SizedBox.shrink(),
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
