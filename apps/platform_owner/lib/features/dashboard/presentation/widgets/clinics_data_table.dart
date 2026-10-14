import 'package:flutter/material.dart';
import '../../domain/entities/tenant_clinic_entity.dart';

class ClinicsDataTable extends StatelessWidget {
  final List<TenantClinicEntity> clinics;
  final ValueChanged<TenantClinicEntity> onDetails;
  final ValueChanged<TenantClinicEntity> onManagePlan;
  final ValueChanged<TenantClinicEntity> onToggleStatus;
  final ValueChanged<TenantClinicEntity> onResendInvite;
  final ValueChanged<TenantClinicEntity> onDelete;

  const ClinicsDataTable({
    super.key,
    required this.clinics,
    required this.onDetails,
    required this.onManagePlan,
    required this.onToggleStatus,
    required this.onResendInvite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (clinics.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: const Text('No clinics found matching criteria.', style: TextStyle(color: Colors.white60)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth > 980 ? constraints.maxWidth : 980.0;
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
              child: Column(children: [_header(), ...clinics.map((c) => _row(c))]),
            ),
          ),
        );
      },
    );
  }

  Widget _header() => Container(
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const BoxDecoration(
      color: Color(0xFF131D31),
      border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
    ),
    child: const Row(children: [
      Expanded(flex: 30, child: Text('CLINIC FACILITY', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
      Expanded(flex: 16, child: Text('SUBSCRIPTION PLAN', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
      Expanded(flex: 22, child: Text('ADMIN CONTACT', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
      Expanded(flex: 12, child: Text('STATUS', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
      Expanded(flex: 22, child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)))),
    ]),
  );

  Widget _row(TenantClinicEntity c) => Container(
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF1E293B)))),
    child: Row(children: [
      // 1. Clinic Facility
      Expanded(
        flex: 30,
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF0284C7),
              child: Text(
                c.name.isNotEmpty ? c.name.substring(0, 1).toUpperCase() : 'C',
                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${c.category} • ${c.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 2. Subscription Plan
      Expanded(
        flex: 16,
        child: Align(
          alignment: Alignment.centerLeft,
          child: _planBadge(c.planName),
        ),
      ),

      // 3. Admin Contact
      Expanded(
        flex: 22,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.adminName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 1),
            Text(
              c.adminEmail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ],
        ),
      ),

      // 4. Status Chip
      Expanded(
        flex: 12,
        child: Align(
          alignment: Alignment.centerLeft,
          child: _statusChip(c.status),
        ),
      ),

      // 5. Actions (Reverted from 3-dot dropdown to dedicated buttons)
      Expanded(
        flex: 22,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _actionBtn(
              'Details',
              const Color(0xFF1E293B),
              const Color(0xFFE2E8F0),
              () => onDetails(c),
            ),
            const SizedBox(width: 6),
            _actionBtn(
              'Plan',
              const Color(0xFF0C4A6E),
              const Color(0xFF38BDF8),
              () => onManagePlan(c),
            ),
            const SizedBox(width: 6),
            if (c.isInvited)
              _actionBtn(
                'Resend',
                const Color(0xFF1E3A8A),
                const Color(0xFF60A5FA),
                () => onResendInvite(c),
              )
            else
              _actionBtn(
                c.isActive ? 'Pause' : 'Activate',
                c.isActive ? const Color(0xFF78350F) : const Color(0xFF064E3B),
                c.isActive ? const Color(0xFFFBBF24) : const Color(0xFF34D399),
                () => onToggleStatus(c),
              ),
            const SizedBox(width: 6),
            _iconActionBtn(
              Icons.delete_outline_rounded,
              const Color(0xFF450A0A),
              const Color(0xFFEF4444),
              'Delete Clinic & Admin',
              () => onDelete(c),
            ),
          ],
        ),
      ),
    ]),
  );

  Widget _planBadge(String planName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0C4A6E).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
      ),
      child: Text(
        planName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF38BDF8),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusChip(String s) {
    final isTrial = s == 'TRIAL', isSusp = s == 'SUSPENDED', isInvited = s == 'INVITED';
    final bg = isInvited
        ? const Color(0xFF1E3A8A)
        : (isTrial
            ? const Color(0xFF78350F)
            : (isSusp ? const Color(0xFF7F1D1D) : const Color(0xFF064E3B)));
    final fg = isInvited
        ? const Color(0xFF60A5FA)
        : (isTrial
            ? const Color(0xFFFBBF24)
            : (isSusp ? const Color(0xFFF87171) : const Color(0xFF34D399)));
    final label = isInvited ? 'INVITED' : s;
    return Tooltip(
      message: isInvited
          ? 'Invite email sent. Waiting for clinic admin to activate account via link.'
          : 'Status: $s',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _actionBtn(String label, Color bg, Color fg, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: fg.withValues(alpha: 0.25)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _iconActionBtn(IconData icon, Color bg, Color fg, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: fg.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, size: 14, color: fg),
        ),
      ),
    );
  }
}
