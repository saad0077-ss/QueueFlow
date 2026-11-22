import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../billing/presentation/pages/platform_billing_page.dart';
import '../../../dashboard/presentation/pages/platform_clinics_page.dart';
import '../../../dashboard/presentation/widgets/console_sidebar.dart';
import '../../../dashboard/presentation/widgets/console_top_bar.dart';
import '../../../departments/presentation/pages/platform_departments_page.dart';
import '../../data/repositories/platform_users_repository_impl.dart';
import '../../domain/entities/platform_user_entity.dart';
import '../widgets/delete_patient_dialog.dart';
import '../widgets/platform_users_data_table.dart';
import '../widgets/platform_users_filter_toolbar.dart';
import '../widgets/platform_users_header_bar.dart';
import '../widgets/platform_users_kpi_cards.dart';

class PlatformUsersPage extends StatefulWidget {
  const PlatformUsersPage({super.key});

  @override
  State<PlatformUsersPage> createState() => _PlatformUsersPageState();
}

class _PlatformUsersPageState extends State<PlatformUsersPage> {
  final _repo = PlatformUsersRepositoryImpl();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedClinic = 'all';
  String _selectedStatus = 'all';

  void _onSidebarNav(int i) {
    if (i == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const PlatformClinicsPage(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (i == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const PlatformDepartmentsPage(),
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

  void _confirmDeleteUser(PlatformUserEntity user) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => DeletePatientDialog(
        user: user,
        onConfirm: () async {
          await _repo.deletePatientAccount(user.id, email: user.email);
        },
      ),
    );

    if (deleted == true && mounted) {
      AppSnackBar.showSuccess(
        context,
        message: 'Patient ${user.name} and all records permanently purged from Firestore & Storage.',
      );
    }
  }

  void _exportCsv(List<PlatformUserEntity> users) {
    AppSnackBar.showSuccess(
      context,
      message: 'Exported ${users.length} patient records to CSV.',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                activeIndex: 2,
                onIndexChanged: _onSidebarNav,
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            ConsoleSidebar(
              activeIndex: 2,
              onIndexChanged: _onSidebarNav,
            ),
          Expanded(
            child: Builder(
              builder: (ctx) => Column(
                children: [
                  ConsoleTopBar(
                    onMenuPressed: isDesktop ? null : () => Scaffold.of(ctx).openDrawer(),
                    onSearch: (q) => setState(() {
                      _searchQuery = q.trim().toLowerCase();
                      _searchController.text = q;
                    }),
                  ),
                  Expanded(
                    child: StreamBuilder<List<PlatformUserEntity>>(
                      stream: _repo.watchPlatformUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }

                        final allUsers = snapshot.data ?? const [];

                        // Compute list of available clinic names for dropdown filter
                        final clinicsSet = <String>{};
                        for (final u in allUsers) {
                          if (u.homeClinicName.isNotEmpty) {
                            clinicsSet.add(u.homeClinicName);
                          }
                        }
                        final availableClinics = clinicsSet.toList()..sort();

                        // Filter users based on search, clinic, and status
                        final filteredUsers = allUsers.where((u) {
                          if (_searchQuery.isNotEmpty) {
                            final matchName = u.name.toLowerCase().contains(_searchQuery);
                            final matchEmail = u.email.toLowerCase().contains(_searchQuery);
                            final matchPhone = u.phone.toLowerCase().contains(_searchQuery);
                            final matchHealth = u.healthId.toLowerCase().contains(_searchQuery);
                            final matchToken = (u.activeQueueToken ?? '').toLowerCase().contains(_searchQuery);
                            final matchClinic = u.homeClinicName.toLowerCase().contains(_searchQuery);
                            if (!matchName && !matchEmail && !matchPhone && !matchHealth && !matchToken && !matchClinic) {
                              return false;
                            }
                          }

                          if (_selectedClinic != 'all' && u.homeClinicName != _selectedClinic) {
                            return false;
                          }

                          if (_selectedStatus == 'in-queue') {
                            if (u.activeQueueToken == null || u.activeQueueToken!.isEmpty) return false;
                          } else if (_selectedStatus == 'verified') {
                            if (!u.isVerified) return false;
                          } else if (_selectedStatus == 'active') {
                            if (u.status != 'active') return false;
                          }

                          return true;
                        }).toList();

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PlatformUsersHeaderBar(
                                totalCount: allUsers.length,
                                onRefresh: () => setState(() {}),
                                onExport: () => _exportCsv(filteredUsers),
                              ),
                              const SizedBox(height: 20),
                              PlatformUsersKpiCards(users: allUsers),
                              const SizedBox(height: 20),
                              PlatformUsersFilterToolbar(
                                searchController: _searchController,
                                selectedClinic: _selectedClinic,
                                selectedStatus: _selectedStatus,
                                availableClinics: availableClinics,
                                filteredCount: filteredUsers.length,
                                onSearchChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                                onClinicChanged: (val) => setState(() => _selectedClinic = val),
                                onStatusChanged: (val) => setState(() => _selectedStatus = val),
                                onReset: () => setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                  _selectedClinic = 'all';
                                  _selectedStatus = 'all';
                                }),
                              ),
                              const SizedBox(height: 16),
                              PlatformUsersDataTable(
                                users: filteredUsers,
                                onDeleteUser: _confirmDeleteUser,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
