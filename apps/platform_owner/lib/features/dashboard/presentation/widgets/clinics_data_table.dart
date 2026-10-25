import 'package:flutter/material.dart';

import '../../../departments/domain/entities/department_entity.dart';
import '../../domain/entities/tenant_clinic_entity.dart';

class ClinicsDataTable extends StatelessWidget {
  final List<TenantClinicEntity> clinics;
  final ValueChanged<TenantClinicEntity> onDetails;
  final ValueChanged<TenantClinicEntity>? onEdit;
  final ValueChanged<TenantClinicEntity> onManagePlan;
  final ValueChanged<TenantClinicEntity> onToggleStatus;
  final ValueChanged<TenantClinicEntity> onResendInvite;
  final ValueChanged<TenantClinicEntity> onDelete;
  final List<DepartmentEntity> departments;
  final Map<String, int> appointmentsByClinic;

  static const _avatarGradients = [
    [Color(0xFF2563EB), Color(0xFF06B6D4)],
    [Color(0xFF0F766E), Color(0xFF14B8A6)],
    [Color(0xFF7C3AED), Color(0xFFA855F7)],
    [Color(0xFFD97706), Color(0xFFF59E0B)],
    [Color(0xFFDB2777), Color(0xFFF472B6)],
    [Color(0xFF475569), Color(0xFF94A3B8)],
  ];

  static const _headerStyle = TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5);

  const ClinicsDataTable({
    super.key,
    required this.clinics,
    required this.onDetails,
    this.onEdit,
    required this.onManagePlan,
    required this.onToggleStatus,
    required this.onResendInvite,
    required this.onDelete,
    this.departments = const [],
    this.appointmentsByClinic = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (clinics.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.domain_disabled_outlined, color: Color(0xFF334155), size: 36),
            SizedBox(height: 10),
            Text('No clinics found', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Onboard a clinic or adjust your filters.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth > 1040 ? constraints.maxWidth : 1040.0;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _header(),
                  for (var i = 0; i < clinics.length; i++)
                    _ClinicRow(
                      clinic: clinics[i],
                      gradient: _avatarGradients[i % _avatarGradients.length],
                      departments: _departmentsFor(clinics[i]),
                      appointments: appointmentsByClinic[clinics[i].id] ?? 0,
                      isLast: i == clinics.length - 1,
                      table: this,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header() => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: const BoxDecoration(
      color: Color(0xFF131D31),
      border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
    ),
    child: const Row(
      children: [
        Expanded(flex: 28, child: Text('CLINIC FACILITY', style: _headerStyle)),
        Expanded(flex: 15, child: Text('SUBSCRIPTION', style: _headerStyle)),
        Expanded(flex: 20, child: Text('ADMIN CONTACT', style: _headerStyle)),
        Expanded(flex: 13, child: Text('ACTIVITY', style: _headerStyle)),
        Expanded(flex: 11, child: Text('STATUS', style: _headerStyle)),
        Expanded(
          flex: 17,
          child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: _headerStyle)),
        ),
      ],
    ),
  );

  /// Departments linked to [c], matched by clinic departmentIds, Firestore id or legacy name slug
  List<DepartmentEntity> _departmentsFor(TenantClinicEntity c) {
    final slug = c.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return departments.where((d) {
      if (c.departmentIds.contains(d.id)) return true;
      return d.assignedClinics.any((k) => k == c.id || (k.isNotEmpty && slug.startsWith(k)));
    }).toList();
  }
}

class _ClinicRow extends StatefulWidget {
  final TenantClinicEntity clinic;
  final List<Color> gradient;
  final List<DepartmentEntity> departments;
  final int appointments;
  final bool isLast;
  final ClinicsDataTable table;

  const _ClinicRow({
    required this.clinic,
    required this.gradient,
    required this.departments,
    required this.appointments,
    required this.isLast,
    required this.table,
  });

  @override
  State<_ClinicRow> createState() => _ClinicRowState();
}

class _ClinicRowState extends State<_ClinicRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.clinic;
    final t = widget.table;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: () => t.onDetails(c),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF131D31) : Colors.transparent,
            border: Border(
              left: BorderSide(color: _hovered ? widget.gradient.last : Colors.transparent, width: 3),
              bottom: widget.isLast ? BorderSide.none : const BorderSide(color: Color(0xFF1E293B)),
            ),
          ),
          child: Row(
            children: [
              Expanded(flex: 28, child: _facilityCell(c)),
              Expanded(flex: 15, child: _planCell(c)),
              Expanded(flex: 20, child: _adminCell(c)),
              Expanded(flex: 13, child: _activityCell(c)),
              Expanded(
                flex: 11,
                child: Align(alignment: Alignment.centerLeft, child: _statusChip(c)),
              ),
              Expanded(flex: 17, child: _actionsCell(c, t)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _facilityCell(TenantClinicEntity c) {
    final initials = c.name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();
    final location = [c.address, c.city].where((s) => s.trim().isNotEmpty).join(', ');

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            initials.isEmpty ? 'C' : initials,
            style: const TextStyle(fontSize: 13.5, color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.5),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      location.isEmpty ? 'Location not set' : location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ),
                ],
              ),
              if (widget.departments.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(spacing: 5, runSpacing: 5, children: [for (final d in widget.departments) _deptChip(d)]),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _planCell(TenantClinicEntity c) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0C4A6E).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
            ),
            child: Text(
              c.planName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            c.doctorLimitText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  Widget _adminCell(TenantClinicEntity c) {
    final hasName = c.adminName.trim().isNotEmpty;
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFF1E293B),
          child: Text(
            hasName ? c.adminName.trim()[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 11, color: Color(0xFFE2E8F0), fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasName ? c.adminName : 'Not assigned',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: hasName ? Colors.white : const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                c.adminEmail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _activityCell(TenantClinicEntity c) {
    final doctors = c.doctors.length;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _metric(Icons.medical_services_outlined, '$doctors doctor${doctors == 1 ? '' : 's'}'),
        const SizedBox(height: 4),
        _metric(Icons.calendar_today_rounded, '${widget.appointments} this month'),
      ],
    );
  }

  Widget _metric(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF64748B)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5),
          ),
        ),
      ],
    );
  }

  Widget _deptChip(DepartmentEntity d) {
    return Tooltip(
      message: d.name,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF064E3B).withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
        ),
        child: Text(
          d.code,
          style: const TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.3),
        ),
      ),
    );
  }

  Widget _statusChip(TenantClinicEntity c) {
    final (Color fg, String tip) = switch (c.status) {
      'ACTIVE' => (const Color(0xFF34D399), 'Clinic is live and accepting patients.'),
      'INVITED' => (const Color(0xFF60A5FA), 'Invite email sent. Waiting for clinic admin to activate account via link.'),
      'TRIAL' => (const Color(0xFFFBBF24), 'Clinic is on a trial subscription.'),
      'SUSPENDED' => (const Color(0xFFF87171), 'Clinic is paused. Booking and queue tokens are frozen.'),
      _ => (const Color(0xFF94A3B8), 'Status: ${c.status}'),
    };
    return Tooltip(
      message: tip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: fg.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: fg.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(c.status, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _actionsCell(TenantClinicEntity c, ClinicsDataTable t) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        if (t.onEdit != null) _iconBtn(Icons.edit_outlined, const Color(0xFF38BDF8), 'Edit clinic', () => t.onEdit!(c)),
        _iconBtn(Icons.workspace_premium_outlined, const Color(0xFFA78BFA), 'Manage plan', () => t.onManagePlan(c)),
        if (c.isInvited)
          _iconBtn(Icons.send_rounded, const Color(0xFF60A5FA), 'Resend invite', () => t.onResendInvite(c))
        else
          _iconBtn(
            c.isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
            c.isActive ? const Color(0xFFFBBF24) : const Color(0xFF34D399),
            c.isActive ? 'Pause clinic' : 'Activate clinic',
            () => t.onToggleStatus(c),
          ),
        _iconBtn(Icons.delete_outline_rounded, const Color(0xFFEF4444), 'Delete clinic & admin', () => t.onDelete(c)),
        _iconBtn(Icons.chevron_right_rounded, const Color(0xFFE2E8F0), 'View details', () => t.onDetails(c)),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color fg, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: fg.withValues(alpha: 0.22)),
          ),
          child: Icon(icon, size: 15, color: fg),
        ),
      ),
    );
  }
}
