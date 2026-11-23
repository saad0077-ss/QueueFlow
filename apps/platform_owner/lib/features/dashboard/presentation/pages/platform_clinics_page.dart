import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import '../bloc/clinics_directory_bloc.dart';
import '../widgets/clinic_details/clinic_details_view.dart';
import '../../../departments/data/repositories/department_repository_impl.dart';
import '../../../departments/presentation/pages/platform_departments_page.dart';
import '../../../billing/presentation/pages/platform_billing_page.dart';
import '../../../users/presentation/pages/platform_users_page.dart';
import '../../../tickets/presentation/pages/platform_support_tickets_page.dart';
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
    if (i == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const PlatformDepartmentsPage(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (i == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const PlatformUsersPage(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (i == 3) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const PlatformSupportTicketsPage(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (i == 4) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const PlatformBillingPage(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  void _resendClinicInvite(TenantClinicEntity c) async {
    try {
      final res = await repo.resendInvite(
        clinicId: c.id,
        clinicName: c.name,
        adminName: c.adminName,
        adminEmail: c.adminEmail,
      );
      await Clipboard.setData(ClipboardData(text: res.inviteUrl));
      if (!mounted) return;
      if (res.emailDelivered) {
        AppSnackBar.showSuccess(
          context,
          message:
              'Invite resent to ${c.adminEmail}! Activation link copied to clipboard.',
        );
      } else if (res.emailFeedback != null) {
        AppSnackBar.showWarning(
          context,
          message:
              'Link copied to clipboard. Sandbox note: ${res.emailFeedback}',
        );
      } else {
        AppSnackBar.showSuccess(
          context,
          message: 'Activation link copied to clipboard for ${c.adminEmail}.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, message: 'Failed to resend invite: $e');
      }
    }
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
                      onResendInvite: _resendClinicInvite,
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
