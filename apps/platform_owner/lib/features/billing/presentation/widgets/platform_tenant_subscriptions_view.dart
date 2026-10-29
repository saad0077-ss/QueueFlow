import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/platform_tenant_subscription_entity.dart';

class PlatformTenantSubscriptionsView extends StatelessWidget {
  final List<PlatformTenantSubscriptionEntity> subscriptions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PlatformTenantSubscriptionEntity> onManageSubscription;
  final ValueChanged<PlatformTenantSubscriptionEntity> onIssueInvoice;

  const PlatformTenantSubscriptionsView({
    super.key,
    required this.subscriptions,
    required this.onSearchChanged,
    required this.onManageSubscription,
    required this.onIssueInvoice,
  });

  static const _avatarColors = [
    Color(0xFF2563EB),
    Color(0xFF0F766E),
    Color(0xFF7C3AED),
    Color(0xFFF59E0B),
    Color(0xFF14B8A6),
    Color(0xFF64748B),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partner Clinic Subscriptions',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manage plan tiers, billing cycles, quotas, and renewal states per practice',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 250,
                    child: TextField(
                      onChanged: onSearchChanged,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search clinic, plan, admin...',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF162238),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF334E7A),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: constraints.maxWidth < 1100
                    ? 1100
                    : constraints.maxWidth,
                child: Column(
                  children: [
                    _headerRow(),
                    const Divider(color: Color(0xFF1E293B), height: 1),
                    if (subscriptions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Text(
                          'No clinics match your search.',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ...subscriptions.asMap().entries.map(
                      (e) => _dataRow(e.key, e.value),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    Widget h(String t, {TextAlign align = TextAlign.left}) => Text(
      t.toUpperCase(),
      textAlign: align,
      style: GoogleFonts.inter(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF94A3B8),
        letterSpacing: 0.8,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 30, child: h('Clinic')),
          Expanded(flex: 21, child: h('Admin Contact')),
          Expanded(flex: 23, child: h('Current Plan')),
          Expanded(flex: 15, child: h('Billing Cycle')),
          Expanded(flex: 12, child: h('MRR Rate')),
          Expanded(flex: 14, child: h('Status')),
          Expanded(flex: 25, child: h('Actions', align: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _dataRow(int index, PlatformTenantSubscriptionEntity s) {
    final cycle = s.billingCadence.toLowerCase().contains('annual')
        ? 'Annual'
        : 'Monthly';
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 30,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _avatarColors[index % _avatarColors.length],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _initials(s.clinicName),
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.clinicName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        s.city,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 21,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.adminName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                ),
                Text(
                  s.adminEmail,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 23,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _planBadge(s.planName),
            ),
          ),
          Expanded(
            flex: 15,
            child: Text(
              cycle,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              s.mrrAmount,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 14,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusPill(s.status),
            ),
          ),
          Expanded(
            flex: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton('Change Plan', () => onManageSubscription(s)),
                const SizedBox(width: 8),
                _actionButton('+ Invoice', () => onIssueInvoice(s)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _actionButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF334155)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _planBadge(String planName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withAlpha(110),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        planName,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF3B82F6),
        ),
      ),
    );
  }

  Widget _statusPill(String status) {
    final upper = status.toUpperCase();
    final color = upper == 'ACTIVE'
        ? const Color(0xFF22C55E)
        : upper == 'TRIAL'
        ? const Color(0xFF3B82F6)
        : upper == 'SUSPENDED'
        ? const Color(0xFF6366F1)
        : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        upper,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
