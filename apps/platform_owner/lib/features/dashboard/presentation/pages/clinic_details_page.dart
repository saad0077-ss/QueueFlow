import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/models/tenant_clinic_model.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import '../widgets/console_sidebar.dart';
import '../widgets/manage_subscription_modal.dart';
import '../widgets/edit_clinic_modal.dart';

class ClinicDetailsPage extends StatelessWidget {
  final TenantClinicEntity clinic;
  final TenantRepositoryImpl repo;
  final VoidCallback? onBack;

  const ClinicDetailsPage({super.key, required this.clinic, required this.repo, this.onBack});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFF070B14),
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
                  _topNavigation(context, clinic),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16, vertical: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _heroBanner(context, clinic),
                          const SizedBox(height: 20),
                          _kpiMetricsGrid(context, clinic),
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

  Widget _topNavigation(BuildContext context, TenantClinicEntity clinic) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 12),
      decoration: const BoxDecoration(
        color: Color(0xFF070B14),
        border: Border(bottom: BorderSide(color: Color(0xFF131D31), width: 1)),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
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
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    'Clinics Directory',
                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('/', style: GoogleFonts.inter(color: const Color(0xFF334155), fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              clinic.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          _statusPill(clinic.status, clinic.isInvited),
        ],
      ),
    );
  }

  Widget _heroBanner(BuildContext context, TenantClinicEntity clinic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F1A2E), Color(0xFF0A101D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1050;
          final identity = Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF06B6D4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))],
                ),
                alignment: Alignment.center,
                child: Text(
                  clinic.name.isNotEmpty ? clinic.name.substring(0, 1).toUpperCase() : 'C',
                  style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.name,
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4),
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
                            bg: const Color(0xFF064E3B).withValues(alpha: 0.6),
                            fg: const Color(0xFF34D399),
                          ),
                        if (clinic.city.isNotEmpty)
                          _badge(icon: Icons.location_on_outlined, label: clinic.city, bg: const Color(0xFF1E293B), fg: const Color(0xFF94A3B8)),
                        _badge(
                          icon: Icons.credit_card_rounded,
                          label: clinic.planName,
                          bg: const Color(0xFF0C4A6E).withValues(alpha: 0.5),
                          fg: const Color(0xFF38BDF8),
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
                icon: Icons.edit_note_rounded,
                label: 'Edit Clinic Details',
                bg: const Color(0xFF1E293B),
                fg: const Color(0xFF38BDF8),
                onTap: () => EditClinicModal.show(context, clinic),
              ),
              _headerActionButton(
                icon: Icons.tune_rounded,
                label: 'Manage Subscription',
                bg: const Color(0xFF0C4A6E),
                fg: const Color(0xFF38BDF8),
                onTap: () => ManageSubscriptionModal.show(context, clinic),
              ),
              if (clinic.isInvited)
                _headerActionButton(
                  icon: Icons.send_rounded,
                  label: 'Resend Invitation Email',
                  bg: const Color(0xFF1E3A8A),
                  fg: const Color(0xFF60A5FA),
                  onTap: () => _resendInvite(context, clinic),
                )
              else
                _headerActionButton(
                  icon: clinic.isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                  label: clinic.isActive ? 'Pause Clinic Practice' : 'Activate Clinic Practice',
                  bg: clinic.isActive ? const Color(0xFF78350F) : const Color(0xFF064E3B),
                  fg: clinic.isActive ? const Color(0xFFFBBF24) : const Color(0xFF34D399),
                  onTap: () => _toggleClinicStatus(context, clinic),
                ),
              _headerActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Clinic Facility',
                bg: const Color(0xFF450A0A),
                fg: const Color(0xFFEF4444),
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
              const Divider(color: Color(0xFF1E293B), height: 1),
              const SizedBox(height: 16),
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _kpiMetricsGrid(BuildContext context, TenantClinicEntity clinic) {
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
                icon: Icons.medical_services_outlined,
                color: const Color(0xFFA855F7),
                title: 'DOCTORS ON ROSTER',
                value: '${clinic.doctors.length} Doctor${clinic.doctors.length == 1 ? '' : 's'}',
                subtitle: clinic.doctorLimitText,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _kpiCard(
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

  Widget _kpiCard({required IconData icon, required Color color, required String title, required String value, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        gradient: LinearGradient(
          colors: [Color.alphaBlend(color.withValues(alpha: 0.07), const Color(0xFF0F172A)), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.center,
        ),
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
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _leftColumn(BuildContext context, TenantClinicEntity clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_facilityDetailsCard(context, clinic), const SizedBox(height: 20), _doctorsRosterCard(context, clinic)],
    );
  }

  Widget _rightColumn(BuildContext context, TenantClinicEntity clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_administratorProfileCard(context, clinic), const SizedBox(height: 20), _platformGovernanceCard(context, clinic)],
    );
  }

  Widget _facilityDetailsCard(BuildContext context, TenantClinicEntity clinic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.business_rounded,
            color: const Color(0xFF38BDF8),
            title: 'Facility & Location Profile',
            trailing: InkWell(
              onTap: () => EditClinicModal.show(context, clinic),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_note_rounded, size: 15, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 4),
                    Text(
                      'Edit Details',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF38BDF8)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _detailRow(icon: Icons.medical_services_outlined, label: 'Assigned Departments / Specialties', value: _orNotSet(clinic.category)),
          _detailRow(
            icon: Icons.location_on_outlined,
            label: 'Physical Facility Address',
            value: _orNotSet(clinic.address),
            onCopy: clinic.address.isEmpty ? null : () => _copyToClipboard(context, clinic.address, 'Address'),
          ),
          _detailRow(icon: Icons.location_city_outlined, label: 'City & Jurisdiction', value: _orNotSet(clinic.city)),
          _detailRow(
            icon: Icons.phone_outlined,
            label: 'Clinic Contact Line',
            value: _orNotSet(clinic.phone),
            onCopy: clinic.phone.isEmpty ? null : () => _copyToClipboard(context, clinic.phone, 'Phone Number'),
          ),
          _detailRow(icon: Icons.schedule_rounded, label: 'Facility Operating Hours', value: _orNotSet(clinic.operatingHours)),
          _detailRow(
            icon: Icons.confirmation_number_outlined,
            label: 'Live Queue & Wait Time',
            value: _queueSummary == null ? 'No queue activity yet' : '${_queueSummary!.status} • ${_queueSummary!.detail}',
          ),
        ],
      ),
    );
  }

  Widget _doctorsRosterCard(BuildContext context, TenantClinicEntity clinic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.medical_services_outlined,
            color: const Color(0xFFA855F7),
            title: 'Practicing Medical Team (${clinic.doctors.length})',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
              ),
              child: Text(
                clinic.doctorLimitText,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFC084FC)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (clinic.doctors.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No doctors added yet. The clinic admin adds doctors from their portal.',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
              ),
            )
          else
            for (final doc in clinic.doctors) _doctorTile(name: doc.name, specialty: doc.specialty, room: doc.room, isAvailable: doc.isAvailable),
        ],
      ),
    );
  }

  Widget _doctorTile({required String name, required String specialty, required String room, required bool isAvailable}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
            child: const Icon(Icons.person_rounded, color: Color(0xFF60A5FA), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text([specialty, room].where((s) => s.isNotEmpty).join(' • '), style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAvailable ? const Color(0xFF064E3B).withValues(alpha: 0.6) : const Color(0xFF78350F).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isAvailable ? 'AVAILABLE' : 'OFF DUTY',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isAvailable ? const Color(0xFF34D399) : const Color(0xFFFBBF24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _administratorProfileCard(BuildContext context, TenantClinicEntity clinic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(icon: Icons.admin_panel_settings_outlined, color: const Color(0xFF38BDF8), title: 'Clinic Administrator Profile'),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF0284C7),
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
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text('Medical Director & Clinic Admin', style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            decoration: BoxDecoration(
              color: const Color(0xFF131D31),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Row(
              children: [
                const Icon(Icons.email_outlined, size: 16, color: Color(0xFF38BDF8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    clinic.adminEmail,
                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                _copyButton(() => _copyToClipboard(context, clinic.adminEmail, 'Email Address'), tooltip: 'Copy Email'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Account Activation Status Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: clinic.isInvited
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.25)
                  : (clinic.isActive ? const Color(0xFF064E3B).withValues(alpha: 0.25) : const Color(0xFF7F1D1D).withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: clinic.isInvited
                    ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
                    : (clinic.isActive ? const Color(0xFF10B981).withValues(alpha: 0.4) : const Color(0xFFEF4444).withValues(alpha: 0.4)),
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
                      color: clinic.isInvited ? const Color(0xFF60A5FA) : (clinic.isActive ? const Color(0xFF34D399) : const Color(0xFFF87171)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      clinic.isInvited ? 'Invitation Pending Activation' : (clinic.isActive ? 'Account Active & Verified' : 'Practice Suspended'),
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: clinic.isInvited ? const Color(0xFF60A5FA) : (clinic.isActive ? const Color(0xFF34D399) : const Color(0xFFF87171)),
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
                  style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFFCBD5E1), height: 1.35),
                ),
                if (clinic.isInvited) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(icon: Icons.shield_outlined, color: const Color(0xFF10B981), title: 'Platform Governance'),
          const SizedBox(height: 10),
          _metaRow('Clinic Unique ID:', clinic.id, onCopy: () => _copyToClipboard(context, clinic.id, 'Clinic ID')),
          _metaRow('Security Policy:', 'Firebase Multi-Tenant Firestore Isolated'),
          _metaRow('Billing Schedule:', '${clinic.planName} (${clinic.billingCadence})'),
          _metaRow('Registration Status:', clinic.status),
        ],
      ),
    );
  }

  Widget _sectionHeader({required IconData icon, required Color color, required String title, Widget? trailing}) {
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
                style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFF1E293B), height: 1),
      ],
    );
  }

  Widget _copyButton(VoidCallback onCopy, {String tooltip = 'Copy'}) {
    return IconButton(
      icon: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF64748B)),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      onPressed: onCopy,
    );
  }

  Widget _detailRow({required IconData icon, required String label, required String value, VoidCallback? onCopy}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF131D31),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF38BDF8)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFFF1F5F9), fontWeight: FontWeight.w600, height: 1.3),
                ),
              ],
            ),
          ),
          if (onCopy != null) _copyButton(onCopy),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value, {VoidCallback? onCopy}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onCopy != null) _copyButton(onCopy),
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
          // Flexible lets long labels (e.g. many joined department names) ellipsize instead of overflowing
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

  Widget _headerActionButton({required IconData icon, required String label, required Color bg, required Color fg, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: fg.withValues(alpha: 0.35)),
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
      await widget.repo.toggleStatus(c.id, c.isActive);
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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.65), blurRadius: 40, offset: const Offset(0, 16))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF7F1D1D).withValues(alpha: 0.35), shape: BoxShape.circle),
                      child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF87171), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Delete Clinic Account',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
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
                  'Are you sure you want to delete "${c.name}"?',
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This action will permanently delete:\n• The clinic facility document\n• Associated pending invites\n• Clinic admin user account\n\nThis cannot be undone.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5, height: 1.45),
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
