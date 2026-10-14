import 'dart:ui';
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
import '../widgets/clinics_data_table.dart';
import '../widgets/clinics_filter_row.dart';
import '../widgets/clinics_header_bar.dart';
import '../widgets/clinics_kpi_cards.dart';
import '../widgets/console_sidebar.dart';
import '../widgets/console_top_bar.dart';
import '../widgets/manage_subscription_modal.dart';
import '../widgets/onboard_clinic_modal.dart';

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
  TenantClinicEntity? _selectedClinic;

  void _showDetails(TenantClinicEntity c) {
    setState(() {
      _selectedClinic = c;
    });
  }

  void _closeDetails() {
    setState(() {
      _selectedClinic = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      drawer: isDesktop ? null : const Drawer(child: ConsoleSidebar(activeIndex: 0)),
      body: Row(
        children: [
          if (isDesktop) const ConsoleSidebar(activeIndex: 0),
          Expanded(
            child: Builder(
              builder: (ctx) {
                if (_selectedClinic != null) {
                  return ClinicDetailsView(
                    clinic: _selectedClinic!,
                    repo: repo,
                    onBack: _closeDetails,
                    onOpenDrawer: isDesktop ? null : () => Scaffold.of(ctx).openDrawer(),
                  );
                }

                return Column(
                  children: [
                    ConsoleTopBar(
                      onMenuPressed: isDesktop ? null : () => Scaffold.of(ctx).openDrawer(),
                      onSearch: (q) => ctx.read<ClinicsDirectoryBloc>().add(ClinicsSearchQueryChanged(q)),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: repo.watchClinics(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final list = snapshot.data!.docs.map((d) => TenantClinicModel.fromFirestore(d)).toList();
                            context.read<ClinicsDirectoryBloc>().add(ClinicsListUpdated(list));
                            if (list.isEmpty) repo.seedSampleClinics();
                          }
                          return BlocBuilder<ClinicsDirectoryBloc, ClinicsDirectoryState>(
                            builder: (context, state) => SingleChildScrollView(
                              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 14.0, vertical: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClinicsHeaderBar(
                                    onExportCsv: () => AppSnackBar.showInfo(context, message: 'Exported clinics to CSV.'),
                                    onRefresh: () => AppSnackBar.showSuccess(context, message: 'Clinics refreshed.'),
                                    onOnboard: () => OnboardClinicModal.show(context),
                                  ),
                                  const SizedBox(height: 18),
                                  ClinicsKpiCards(
                                    totalClinics: state.totalClinics,
                                    activePractices: state.activePractices,
                                    appointmentsMonth: state.totalAppointmentsMonth,
                                    totalMrr: state.totalMrr,
                                  ),
                                  const SizedBox(height: 18),
                                  ClinicsFilterRow(
                                    searchQuery: state.searchQuery,
                                    selectedPlan: state.selectedPlanFilter,
                                    selectedStatus: state.selectedStatusFilter,
                                    count: state.filteredClinics.length,
                                    total: state.totalClinics,
                                    onSearch: (q) => context.read<ClinicsDirectoryBloc>().add(ClinicsSearchQueryChanged(q)),
                                    onPlanChanged: (p) => context.read<ClinicsDirectoryBloc>().add(ClinicsPlanFilterChanged(p)),
                                    onStatusChanged: (s) => context.read<ClinicsDirectoryBloc>().add(ClinicsStatusFilterChanged(s)),
                                    onReset: () => context.read<ClinicsDirectoryBloc>().add(const ClinicsResetFilters()),
                                  ),
                                  const SizedBox(height: 18),
                                  ClinicsDataTable(
                                    clinics: state.filteredClinics,
                                    onDetails: (c) => _showDetails(c),
                                    onManagePlan: (c) => ManageSubscriptionModal.show(context, c),
                                    onToggleStatus: (c) async {  
                                      try {
                                        await repo.toggleStatus(c.id, c.isActive);
                                        if (context.mounted) {
                                          AppSnackBar.showSuccess(
                                            context,
                                            message: c.isActive ? 'Clinic paused.' : 'Clinic activated.',
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          AppSnackBar.showWarning(context, message: e.toString().replaceFirst('Exception: ', ''));
                                        }
                                      }
                                    },
                                    onResendInvite: (c) => _resendClinicInvite(context, c, repo),
                                    onDelete: (c) => _confirmDeleteClinic(context, c, repo),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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

  void _resendClinicInvite(
    BuildContext context,
    TenantClinicEntity c,
    TenantRepositoryImpl repo,
  ) async {  
    try {
      final res = await repo.resendInvite(
        clinicId: c.id,
        clinicName: c.name,
        adminName: c.adminName,
        adminEmail: c.adminEmail,
      );

      await Clipboard.setData(ClipboardData(text: res.inviteUrl));

      if (context.mounted) {
        if (res.emailDelivered) {
          AppSnackBar.showSuccess(
            context,
            message: 'Invite resent to ${c.adminEmail}! Activation link copied to clipboard.',
          );
        } else if (res.emailFeedback != null) {
          AppSnackBar.showWarning(
            context,
            message: 'Link copied to clipboard. Sandbox note: ${res.emailFeedback}',
          );
        } else {
          AppSnackBar.showSuccess(
            context,
            message: 'Activation link copied to clipboard for ${c.adminEmail}.',
          ); 
        }
      }
    } catch (e) { 
      if (context.mounted) { 
        AppSnackBar.showError(context, message: 'Failed to resend invite: $e');
      }
    }
  }

  void _confirmDeleteClinic(
    BuildContext context,
    TenantClinicEntity c,
    TenantRepositoryImpl repo,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1527),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F1D1D).withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFF87171),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Delete Clinic Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to permanently delete "${c.name}"?',
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will permanently delete the clinic record, revoke access for admin "${c.adminEmail}", and delete all pending invites.',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await repo.deleteClinic(c.id, adminEmail: c.adminEmail);
                          if (_selectedClinic?.id == c.id) {
                            _closeDetails();
                          }
                          if (context.mounted) {
                            AppSnackBar.showSuccess(
                              context,
                              message: 'Deleted "${c.name}" and removed admin account.',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackBar.showError(
                              context,
                              message: 'Failed to delete clinic: $e',
                            );
                          }
                        }
                      },
                      child: const Text('Delete Permanently'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
