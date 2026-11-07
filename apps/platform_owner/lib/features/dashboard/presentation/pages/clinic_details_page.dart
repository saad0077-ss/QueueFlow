import '../widgets/clinic_photo_avatar.dart';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/models/tenant_clinic_model.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import '../widgets/clinic_reviews_card.dart';
import '../widgets/console_sidebar.dart';
import '../widgets/manage_subscription_modal.dart';
import '../widgets/edit_clinic_modal.dart';
import '../widgets/suspend_clinic_dialog.dart';

class ClinicDetailsPage extends StatelessWidget {
  final TenantClinicEntity clinic;
  final TenantRepositoryImpl repo;
  final VoidCallback? onBack;

  const ClinicDetailsPage({super.key, required this.clinic, required this.repo, this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colors.background,
      drawer: isDesktop ? null : const Drawer(child: ConsoleSidebar(activeIndex: 0)),
      body: Row(
        children: [
          if (isDesktop) const ConsoleSidebar(activeIndex: 0),
          Expanded(
            child: ClinicDetailsView(
              clinic: clinic,
              repo: repo,
              onBack: onBack ?? () => Navigator.of(context).pop(),
              onOpenDrawer: () => scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ],
      ),
    );
  }
}

class ClinicDetailsView extends StatefulWidget {
  final TenantClinicEntity clinic;
  final TenantRepositoryImpl repo;
  final VoidCallback onBack;
  final VoidCallback? onOpenDrawer;

  const ClinicDetailsView({super.key, required this.clinic, required this.repo, required this.onBack, this.onOpenDrawer});

  @override
  State<ClinicDetailsView> createState() => _ClinicDetailsViewState();
}

class _ClinicDetailsViewState extends State<ClinicDetailsView> {
  late final _clinic$ = FirebaseFirestore.instance.collection('clinics').doc(widget.clinic.id).snapshots();
  late final _queue$ = FirebaseFirestore.instance.collection('queues').doc(widget.clinic.id).snapshots();
  late final _appointments$ = widget.repo.watchMonthlyAppointmentCounts();

  Map<String, dynamic>? _queue;
  int _appointmentsThisMonth = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return StreamBuilder<DocumentSnapshot>(
      stream: _clinic$,
      builder: (context, snapshot) {
        TenantClinicEntity clinic = widget.clinic;
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
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
                  _topNavigation(context, colors, clinic),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16, vertical: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _heroBanner(context, colors, clinic),
                          const SizedBox(height: 20),
                          _kpiMetricsGrid(context, colors, clinic),
                          const SizedBox(height: 22),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 58, child: _leftColumn(context, clinic)),
                                const SizedBox(width: 20),
                                Expanded(flex: 42, child: _rightColumn(context, clinic)),
                              ],
                            )
                          else
                            Column(children: [_leftColumn(context, clinic), const SizedBox(height: 20), _rightColumn(context, clinic)]),
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

  /// Live queue summary from queues/{clinicId}, or null when the clinic has never opened a queue
  ({String status, String detail})? get _queueSummary {
    final q = _queue;
    if (q == null) return null;
    final waiting = (q['waitingCount'] as num?)?.toInt() ?? 0;
    final paused = q['status'] == 'paused';
    final token = (q['currentToken'] as String?)?.trim() ?? '';
    return (
      status: paused ? 'Queue Paused' : 'Queue Open ($waiting in line)',
      detail: token.isEmpty || token == '---' ? 'No token called yet' : 'Now serving $token',
    );
  }

  String _orNotSet(String v) => v.trim().isEmpty ? 'Not provided' : v;

  Widget _topNavigation(BuildContext context, AppColorsExtension colors, TenantClinicEntity clinic) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            IconButton(
              icon: Icon(Icons.menu_rounded, color: colors.textPrimary, size: 22),
              onPressed: () {
                if (widget.onOpenDrawer != null) {
                  widget.onOpenDrawer!();
                } else {
                  Scaffold.maybeOf(context)?.openDrawer();
                }
              },
            ),
            const SizedBox(width: 4),
          ],
          InkWell(
            onTap: widget.onBack,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 16, color: colors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Clinics Directory',
                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('/', style: GoogleFonts.inter(color: colors.textMuted, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              clinic.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          _statusPill(clinic.status, clinic.isInvited),
        ],
      ),
    );
  }

  Widget _heroBanner(BuildContext context, AppColorsExtension colors, TenantClinicEntity clinic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1050;
          final identity = Row(
            children: [
              ClinicPhotoAvatar(clinicId: clinic.id, name: clinic.name, size: 68, radius: 18, fontSize: 24),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.name,
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.4),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (clinic.category.isNotEmpty)
                          _badge(
                            icon: Icons.local_hospital_outlined,
                            label: clinic.category,
                            bg: colors.badgeOpenBg,
                            fg: colors.badgeOpenText,
                          ),
                        if (clinic.city.isNotEmpty)
                          _badge(icon: Icons.location_on_outlined, label: clinic.city, bg: colors.surfaceSecondary, fg: colors.textMuted),
                        _badge(
                          icon: Icons.credit_card_rounded,
                          label: clinic.planName,
                          bg: colors.primaryTint,
                          fg: colors.primaryLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: isWide ? WrapAlignment.end : WrapAlignment.start,
            children: [
              _headerActionButton(
                colors,
                icon: Icons.edit_note_rounded,
                label: 'Edit Clinic Details',
                bg: colors.surfaceSecondary,
                fg: colors.primaryLight,
                onTap: () => EditClinicModal.show(context, clinic),
              ),
              _headerActionButton(
                colors,
                icon: Icons.tune_rounded,
                label: 'Manage Subscription',
                bg: colors.surfaceSecondary,
                fg: colors.primaryLight,
                onTap: () => ManageSubscriptionModal.show(context, clinic),
              ),
              if (clinic.isInvited)
                _headerActionButton(
                  colors,
                  icon: Icons.send_rounded,
                  label: 'Resend Invitation Email',
                  bg: colors.primaryTint,
                  fg: colors.primaryLight,
                  onTap: () => _resendInvite(context, clinic),
                )
              else
                _headerActionButton(
                  colors,
                  icon: clinic.isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                  label: clinic.isActive ? 'Pause Clinic Practice' : 'Activate Clinic Practice',
                  bg: clinic.isActive ? colors.warningTint : colors.badgeOpenBg,
                  fg: clinic.isActive ? colors.warning : colors.badgeOpenText,
                  onTap: () => _toggleClinicStatus(context, clinic),
                ),
              _headerActionButton(
                colors,
                icon: Icons.delete_outline_rounded,
                label: 'Delete Clinic Facility',
                bg: colors.errorTint,
                fg: colors.error,
                onTap: () => _confirmDeleteClinic(context, clinic),
              ),
            ],
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(child: identity),
                const SizedBox(width: 24),
                actions,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              identity,
              const SizedBox(height: 18),
              Divider(color: colors.border, height: 1),
              const SizedBox(height: 16),
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _kpiMetricsGrid(BuildContext context, AppColorsExtension colors, TenantClinicEntity clinic) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final cardWidth = isWide ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _kpiCard(
                colors,
                icon: Icons.workspace_premium_rounded,
                color: const Color(0xFF38BDF8),
                title: 'SUBSCRIPTION PLAN',
                value: clinic.planName,
                subtitle: '${clinic.billingCadence} • Auto-Renewing',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _kpiCard(
                colors,
                icon: Icons.confirmation_number_outlined,
                color: const Color(0xFF10B981),
                title: 'LIVE QUEUE STATUS',
                value: _queueSummary?.status ?? 'No Queue Yet',
                subtitle: _queueSummary?.detail ?? 'Clinic has not opened a queue',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _kpiCard(
                colors,
                icon: Icons.medical_services_outlined,
                color: const Color(0xFFA855F7),
                title: 'DOCTORS ON ROSTER',
                value: '${clinic.doctors.length} Doctor${clinic.doctors.length == 1 ? '' : 's'}',
                subtitle: '${clinic.doctors.where((d) => d.isAvailable).length} available now',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _kpiCard(
                colors,
                icon: Icons.calendar_today_rounded,
                color: const Color(0xFFF59E0B),
                title: 'PATIENT VOLUME',
                value: '$_appointmentsThisMonth Appointment${_appointmentsThisMonth == 1 ? '' : 's'}',
                subtitle: 'Queue tickets this month',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _kpiCard(AppColorsExtension colors, {required IconData icon, required Color color, required String title, required String value, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: colors.textMuted, letterSpacing: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _leftColumn(BuildContext context, TenantClinicEntity clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _facilityDetailsCard(context, clinic),
        const SizedBox(height: 20),
        _doctorsRosterCard(context, clinic),
        const SizedBox(height: 20),
        ClinicReviewsCard(clinicId: clinic.id),
      ],
    );
  }

  Widget _rightColumn(BuildContext context, TenantClinicEntity clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_administratorProfileCard(context, clinic), const SizedBox(height: 20), _platformGovernanceCard(context, clinic)],
    );
  }

  Widget _facilityDetailsCard(BuildContext context, TenantClinicEntity clinic) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            colors,
            icon: Icons.business_rounded,
            color: const Color(0xFF38BDF8),
            title: 'Facility & Location Profile',
            trailing: InkWell(
              onTap: () => EditClinicModal.show(context, clinic),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note_rounded, size: 15, color: colors.primaryLight),
                    const SizedBox(width: 4),
                    Text(
                      'Edit Details',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primaryLight),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _detailRow(colors, icon: Icons.medical_services_outlined, label: 'Assigned Departments / Specialties', value: _orNotSet(clinic.category)),
          _detailRow(
            colors,
            icon: Icons.location_on_outlined,
            label: 'Physical Facility Address',
            value: _orNotSet(clinic.address),
            onCopy: clinic.address.isEmpty ? null : () => _copyToClipboard(context, clinic.address, 'Address'),
          ),
          _detailRow(colors, icon: Icons.location_city_outlined, label: 'City & Jurisdiction', value: _orNotSet(clinic.city)),
          _detailRow(
            colors,
            icon: Icons.phone_outlined,
            label: 'Clinic Contact Line',
            value: _orNotSet(clinic.phone),
            onCopy: clinic.phone.isEmpty ? null : () => _copyToClipboard(context, clinic.phone, 'Phone Number'),
          ),
          _detailRow(colors, icon: Icons.schedule_rounded, label: 'Facility Operating Hours', value: _orNotSet(clinic.operatingHours)),
          _detailRow(
            colors,
            icon: Icons.confirmation_number_outlined,
            label: 'Live Queue & Wait Time',
            value: _queueSummary == null ? 'No queue activity yet' : '${_queueSummary!.status} • ${_queueSummary!.detail}',
          ),
        ],
      ),
    );
  }

  Widget _doctorsRosterCard(BuildContext context, TenantClinicEntity clinic) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            colors,
            icon: Icons.medical_services_outlined,
            color: const Color(0xFFA855F7),
            title: 'Practicing Medical Team (${clinic.doctors.length})',
          ),
          const SizedBox(height: 14),
          if (clinic.doctors.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No doctors added yet. The clinic admin adds doctors from their portal.',
                style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
              ),
            )
          else
            for (final doc in clinic.doctors) _doctorTile(colors, name: doc.name, specialty: doc.specialty, room: doc.room, isAvailable: doc.isAvailable, status: doc.status),
        ],
      ),
    );
  }

  Widget _doctorTile(AppColorsExtension colors, {required String name, required String specialty, required String room, required bool isAvailable, String status = 'available'}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.primaryTint,
            child: Icon(Icons.person_rounded, color: colors.primaryLight, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text([specialty, room].where((s) => s.isNotEmpty).join(' • '), style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAvailable ? colors.badgeOpenBg : colors.warningTint,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.toUpperCase().replaceAll('-', ' '),
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isAvailable ? colors.badgeOpenText : colors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _administratorProfileCard(BuildContext context, TenantClinicEntity clinic) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(colors, icon: Icons.admin_panel_settings_outlined, color: const Color(0xFF38BDF8), title: 'Clinic Administrator Profile'),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.primary,
                child: Text(
                  clinic.adminName.isNotEmpty ? clinic.adminName.substring(0, 1).toUpperCase() : 'A',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.adminName,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text('Clinic Administrator', style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: colors.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    clinic.adminEmail,
                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                ),
                _copyButton(colors, () => _copyToClipboard(context, clinic.adminEmail, 'Email Address'), tooltip: 'Copy Email'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Account Activation Status Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: clinic.isInvited
                  ? colors.primaryTint
                  : (clinic.isActive ? colors.badgeOpenBg : colors.errorTint),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: clinic.isInvited
                    ? colors.primaryLight.withValues(alpha: 0.4)
                    : (clinic.isActive ? colors.success.withValues(alpha: 0.4) : colors.error.withValues(alpha: 0.4)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      clinic.isInvited ? Icons.hourglass_top_rounded : (clinic.isActive ? Icons.verified_rounded : Icons.block_rounded),
                      size: 16,
                      color: clinic.isInvited ? colors.primaryLight : (clinic.isActive ? colors.badgeOpenText : colors.error),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      clinic.isInvited ? 'Invitation Pending Activation' : (clinic.isActive ? 'Account Active & Verified' : 'Practice Suspended'),
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: clinic.isInvited ? colors.primaryLight : (clinic.isActive ? colors.badgeOpenText : colors.error),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  clinic.isInvited
                      ? 'An invitation link was sent to this address. The clinic administrator must click the email link and set their password to activate the portal.'
                      : (clinic.isActive
                            ? 'This clinic admin has authenticated credentials and full operational privileges.'
                            : 'This clinic is paused. Booking and queue tokens are temporarily frozen.'),
                  style: GoogleFonts.inter(fontSize: 11.5, color: colors.textPrimary, height: 1.35),
                ),
                if (clinic.isInvited) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 14),
                      label: Text('Resend Invite & Copy Link', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _resendInvite(context, clinic),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _platformGovernanceCard(BuildContext context, TenantClinicEntity clinic) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(colors, icon: Icons.shield_outlined, color: const Color(0xFF10B981), title: 'Platform Governance'),
          const SizedBox(height: 10),
          _metaRow(colors, 'Clinic Unique ID:', clinic.id, onCopy: () => _copyToClipboard(context, clinic.id, 'Clinic ID')),
          _metaRow(colors, 'Billing Schedule:', '${clinic.planName} (${clinic.billingCadence})'),
          _metaRow(colors, 'Registration Status:', clinic.status),
        ],
      ),
    );
  }

  Widget _sectionHeader(AppColorsExtension colors, {required IconData icon, required Color color, required String title, Widget? trailing}) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: colors.textPrimary),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: colors.border, height: 1),
      ],
    );
  }

  Widget _copyButton(AppColorsExtension colors, VoidCallback onCopy, {String tooltip = 'Copy'}) {
    return IconButton(
      icon: Icon(Icons.copy_rounded, size: 15, color: colors.textMuted),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      onPressed: onCopy,
    );
  }

  Widget _detailRow(AppColorsExtension colors, {required IconData icon, required String label, required String value, VoidCallback? onCopy}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: colors.border),
            ),
            child: Icon(icon, size: 16, color: colors.primaryLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 13.5, color: colors.textPrimary, fontWeight: FontWeight.w600, height: 1.3),
                ),
              ],
            ),
          ),
          if (onCopy != null) _copyButton(colors, onCopy),
        ],
      ),
    );
  }

  Widget _metaRow(AppColorsExtension colors, String label, String value, {VoidCallback? onCopy}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted)),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: colors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onCopy != null) _copyButton(colors, onCopy),
        ],
      ),
    );
  }

  Widget _badge({required IconData icon, required String label, required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Flexible(
            child: Tooltip(
              message: label,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: fg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status, bool isInvited) {
    final isTrial = status == 'TRIAL', isSusp = status == 'SUSPENDED';
    final bg = isInvited ? const Color(0xFF1E3A8A) : (isTrial ? const Color(0xFF78350F) : (isSusp ? const Color(0xFF7F1D1D) : const Color(0xFF064E3B)));
    final fg = isInvited ? const Color(0xFF60A5FA) : (isTrial ? const Color(0xFFFBBF24) : (isSusp ? const Color(0xFFF87171) : const Color(0xFF34D399)));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: fg.withValues(alpha: 0.15), blurRadius: 12)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fg,
              boxShadow: [BoxShadow(color: fg.withValues(alpha: 0.7), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isInvited ? 'INVITED (PENDING)' : status,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: fg, letterSpacing: 0.4),
          ),
        ],
      ),
    );
  }

  Widget _headerActionButton(AppColorsExtension colors, {required IconData icon, required String label, required Color bg, required Color fg, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: fg),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resendInvite(BuildContext context, TenantClinicEntity c) async {
    try {
      final res = await widget.repo.resendInvite(clinicId: c.id, clinicName: c.name, adminName: c.adminName, adminEmail: c.adminEmail);

      await Clipboard.setData(ClipboardData(text: res.inviteUrl));

      if (context.mounted) {
        if (res.emailDelivered) {
          AppSnackBar.showSuccess(context, message: 'Invite resent to ${c.adminEmail}! Activation link copied to clipboard.');
        } else if (res.emailFeedback != null) {
          AppSnackBar.showWarning(context, message: 'Link copied to clipboard. Sandbox notice: ${res.emailFeedback}');
        } else {
          AppSnackBar.showSuccess(context, message: 'Activation link copied to clipboard for ${c.adminEmail}.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, message: 'Failed to resend invite: $e');
      }
    }
  }

  Future<void> _toggleClinicStatus(BuildContext context, TenantClinicEntity c) async {
    try {
      String? reason;
      if (c.isActive) {
        reason = await SuspendClinicDialog.show(context, c);
        if (reason == null) return; // cancelled
      }
      await widget.repo.toggleStatus(c.id, c.isActive, reason: reason);
      if (context.mounted) {
        AppSnackBar.showSuccess(context, message: c.isActive ? 'Clinic paused.' : 'Clinic activated.');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showWarning(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _confirmDeleteClinic(BuildContext context, TenantClinicEntity c) {
    final colors = context.colors;

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
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border, width: 1.2),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 16))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: colors.errorTint, shape: BoxShape.circle),
                      child: Icon(Icons.delete_outline_rounded, color: colors.error, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Delete Clinic Account',
                        style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to delete "${c.name}"?',
                  style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  'This action will permanently delete:\n• The clinic facility document\n• Associated pending invites\n• Clinic admin user account\n\nThis cannot be undone.',
                  style: TextStyle(color: colors.textMuted, fontSize: 12.5, height: 1.45),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await widget.repo.deleteClinic(c.id, adminEmail: c.adminEmail);
                          if (context.mounted) {
                            widget.onBack();
                            AppSnackBar.showSuccess(context, message: 'Deleted "${c.name}" and removed admin account.');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackBar.showError(context, message: 'Failed to delete clinic: $e');
                          }
                        }
                      },
                      child: const Text('Delete Clinic'),
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

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.showSuccess(context, message: '$label copied to clipboard.');
  }
}
