import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/models/tenant_clinic_model.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import '../bloc/clinics_directory_bloc.dart';
import '../bloc/clinics_directory_event.dart';
import '../bloc/clinics_directory_state.dart';
import 'clinic_details_page.dart';
import '../../../departments/data/repositories/department_repository_impl.dart';
import '../../../departments/domain/entities/department_entity.dart';
import '../../../departments/presentation/pages/platform_departments_page.dart';
import '../../../billing/presentation/pages/platform_billing_page.dart';
import '../widgets/clinics_directory_content.dart';
import '../widgets/console_sidebar.dart';
import '../widgets/console_top_bar.dart';

class PlatformClinicsPage extends StatelessWidget {
  const PlatformClinicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => ClinicsDirectoryBloc(), child: const _PlatformClinicsView());
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
    if (i == 1) {
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, _, _) => const PlatformDepartmentsPage(), transitionDuration: Duration.zero));
    } else if (i == 4) {
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, _, _) => const PlatformBillingPage(), transitionDuration: Duration.zero));
    }
  }

  void _resendClinicInvite(TenantClinicEntity c) async {
    try {
      final res = await repo.resendInvite(clinicId: c.id, clinicName: c.name, adminName: c.adminName, adminEmail: c.adminEmail);
      await Clipboard.setData(ClipboardData(text: res.inviteUrl));
      if (!mounted) return;
      if (res.emailDelivered) {
        AppSnackBar.showSuccess(context, message: 'Invite resent to ${c.adminEmail}! Activation link copied to clipboard.');
      } else if (res.emailFeedback != null) {
        AppSnackBar.showWarning(context, message: 'Link copied to clipboard. Sandbox note: ${res.emailFeedback}');
      } else {
        AppSnackBar.showSuccess(context, message: 'Activation link copied to clipboard for ${c.adminEmail}.');
      }
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, message: 'Failed to resend invite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      drawer: isDesktop ? null : Drawer(child: ConsoleSidebar(activeIndex: 0, onIndexChanged: _onSidebarNav)),
      body: Row(
        children: [
          if (isDesktop) ConsoleSidebar(activeIndex: 0, onIndexChanged: _onSidebarNav),
          Expanded(
            child: Builder(
              builder: (ctx) {
                // The directory stays mounted (hidden) while a clinic is open: its streams are
                // single-subscription, so unmounting and remounting would listen to them twice.
                final selected = _selectedClinic;
                return IndexedStack(
                  index: selected == null ? 0 : 1,
                  children: [
                    _directory(ctx, isDesktop),
                    if (selected != null)
                      ClinicDetailsView(
                        key: ValueKey(selected.id),
                        clinic: selected,
                        repo: repo,
                        onBack: () => setState(() => _selectedClinic = null),
                        onOpenDrawer: isDesktop ? null : () => Scaffold.of(ctx).openDrawer(),
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

  Widget _directory(BuildContext ctx, bool isDesktop) {
    return Column(
      children: [
        ConsoleTopBar(onMenuPressed: isDesktop ? null : () => Scaffold.of(ctx).openDrawer(), onSearch: (q) => ctx.read<ClinicsDirectoryBloc>().add(ClinicsSearchQueryChanged(q))),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _clinics$,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final list = snapshot.data!.docs.map((d) => TenantClinicModel.fromFirestore(d)).where((c) => !TenantRepositoryImpl.isDummyClinic(c)).toList();
                context.read<ClinicsDirectoryBloc>().add(ClinicsListUpdated(list));
              }
              return BlocBuilder<ClinicsDirectoryBloc, ClinicsDirectoryState>(
                builder: (context, state) => StreamBuilder<Map<String, int>>(
                  stream: _appointments$,
                  builder: (context, apptSnap) => StreamBuilder<List<DepartmentEntity>>(
                    stream: _departments$,
                    builder: (context, deptSnap) => ClinicsDirectoryContent(
                      isDesktop: isDesktop,
                      state: state,
                      appointments: apptSnap.data ?? const <String, int>{},
                      departments: deptSnap.data ?? const [],
                      repo: repo,
                      onDetails: (c) => setState(() => _selectedClinic = c),
                      onResendInvite: _resendClinicInvite,
                      onClinicDeleted: () {
                        if (_selectedClinic != null) setState(() => _selectedClinic = null);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
