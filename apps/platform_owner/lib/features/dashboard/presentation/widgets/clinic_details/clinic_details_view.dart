import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../data/models/tenant_clinic_model.dart';
import '../../../domain/entities/tenant_clinic_entity.dart';
import '../../../domain/repositories/tenant_repository.dart';
import '../clinic_reviews_card.dart';
import 'clinic_details_administrator_card.dart';
import 'clinic_details_dialog_helper.dart';
import 'clinic_details_doctors_card.dart';
import 'clinic_details_facility_card.dart';
import 'clinic_details_governance_card.dart';
import 'clinic_details_hero_banner.dart';
import 'clinic_details_kpi_grid.dart';
import 'clinic_details_top_bar.dart';

class ClinicDetailsView extends StatefulWidget {
  final TenantClinicEntity clinic;
  final VoidCallback onBack;
  final TenantRepository repo;
  final VoidCallback? onOpenDrawer;

  const ClinicDetailsView({
    super.key,
    required this.clinic,
    required this.onBack,
    required this.repo,
    this.onOpenDrawer,
  });

  @override
  State<ClinicDetailsView> createState() => _ClinicDetailsViewState();
}

class _ClinicDetailsViewState extends State<ClinicDetailsView> {
  late final _clinic$ = FirebaseFirestore.instance
      .collection('clinics')
      .doc(widget.clinic.id)
      .snapshots();
  late final _queue$ = FirebaseFirestore.instance
      .collection('queues')
      .doc(widget.clinic.id)
      .snapshots();
  late final _appointments$ = widget.repo.watchMonthlyAppointmentCounts();

  Map<String, dynamic>? _queue;
  int _appointmentsThisMonth = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return StreamBuilder<DocumentSnapshot>(
      stream: _clinic$,
      builder: (context, snapshot) {
        TenantClinicEntity clinic = widget.clinic;
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          clinic = TenantClinicModel.fromFirestore(snapshot.data!);
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _queue$,
          builder: (context, queueSnap) => StreamBuilder<Map<String, int>>(
            stream: _appointments$,
            builder: (context, apptSnap) {
              _queue = queueSnap.data?.data();
              _appointmentsThisMonth = apptSnap.data?[clinic.id] ?? 0;

              return Column(
                children: [
                  ClinicDetailsTopBar(
                    clinic: clinic,
                    onBack: widget.onBack,
                    onOpenDrawer: widget.onOpenDrawer,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 28 : 16,
                        vertical: 22,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClinicDetailsHeroBanner(
                            clinic: clinic,
                            onResendInvite: (c) =>
                                ClinicDetailsDialogHelper.resendInvite(
                                  context: context,
                                  repo: widget.repo,
                                  clinic: c,
                                ),
                            onToggleStatus: (c) =>
                                ClinicDetailsDialogHelper.toggleClinicStatus(
                                  context: context,
                                  repo: widget.repo,
                                  clinic: c,
                                ),
                            onDeleteClinic: (c) =>
                                ClinicDetailsDialogHelper.confirmDeleteClinic(
                                  context: context,
                                  repo: widget.repo,
                                  clinic: c,
                                  onDeleted: widget.onBack,
                                ),
                          ),
                          const SizedBox(height: 20),
                          ClinicDetailsKpiGrid(
                            clinic: clinic,
                            appointmentsThisMonth: _appointmentsThisMonth,
                            queueSummary: _queueSummary,
                          ),
                          const SizedBox(height: 22),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 58,
                                  child: _leftColumn(context, clinic),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 42,
                                  child: _rightColumn(context, clinic),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _leftColumn(context, clinic),
                                const SizedBox(height: 20),
                                _rightColumn(context, clinic),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _leftColumn(BuildContext context, TenantClinicEntity clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClinicDetailsFacilityCard(clinic: clinic, queueSummary: _queueSummary),
        const SizedBox(height: 20),
        ClinicDetailsDoctorsCard(clinic: clinic),
        const SizedBox(height: 20),
        ClinicReviewsCard(clinicId: clinic.id),
      ],
    );
  }

  Widget _rightColumn(BuildContext context, TenantClinicEntity clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClinicDetailsAdministratorCard(
          clinic: clinic,
          onResendInvite: (c) => ClinicDetailsDialogHelper.resendInvite(
            context: context,
            repo: widget.repo,
            clinic: c,
          ),
        ),
        const SizedBox(height: 20),
        ClinicDetailsGovernanceCard(clinic: clinic),
      ],
    );
  }

  ({String status, String detail})? get _queueSummary {
    final q = _queue;
    if (q == null) return null;
    final waiting = (q['waitingCount'] as num?)?.toInt() ?? 0;
    final paused = q['status'] == 'paused';
    final token = (q['currentToken'] as String?)?.trim() ?? '';
    return (
      status: paused ? 'Queue Paused' : 'Queue Open ($waiting in line)',
      detail: token.isEmpty || token == '---'
          ? 'No token called yet'
          : 'Now serving $token',
    );
  }
}
