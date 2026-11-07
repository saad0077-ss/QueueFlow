import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_tenant_subscription_entity.dart';
import '../../../dashboard/presentation/widgets/clinic_photo_avatar.dart';

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
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
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
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manage plan tiers, billing cycles, quotas, and renewal states per practice',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: colors.textMuted,
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
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search clinic, plan, admin...',
                        hintStyle: GoogleFonts.inter(
                          color: colors.textMuted,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: colors.textMuted,
                        ),
                        filled: true,
                        fillColor: colors.surfaceSecondary,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors.primary,
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
                    _headerRow(colors),
                    Divider(color: colors.border, height: 1),
                    if (subscriptions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Text(
                          'No clinics match your search.',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ...subscriptions.asMap().entries.map(
                      (e) => _dataRow(colors, e.key, e.value),
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

  Widget _headerRow(AppColorsExtension colors) {
    Widget h(String t, {TextAlign align = TextAlign.left}) => Text(
      t.toUpperCase(),
      textAlign: align,
      style: GoogleFonts.inter(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: colors.textMuted,
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

  Widget _dataRow(AppColorsExtension colors, int index, PlatformTenantSubscriptionEntity s) {
    final cycle = s.billingCadence.toLowerCase().contains('annual')
        ? 'Annual'
        : 'Monthly';
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 30,
            child: Row(
              children: [
                ClinicPhotoAvatar(
                  clinicId: s.clinicId,
                  name: s.clinicName,
                  imageUrl: s.imageUrl,
                  size: 36,
                  radius: 10,
                  fontSize: 12.5,
                  gradient: [
                    _avatarColors[index % _avatarColors.length],
                    _avatarColors[(index + 1) % _avatarColors.length],
                  ],
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
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        s.city,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: colors.textMuted,
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
                  style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
                ),
                Text(
                  s.adminEmail,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 23,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _planBadge(colors, s.planName),
            ),
          ),
          Expanded(
            flex: 15,
            child: Text(
              cycle,
              style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              s.mrrAmount,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 14,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusPill(colors, s.status),
            ),
          ),
          Expanded(
            flex: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(colors, 'Change Plan', () => onManageSubscription(s)),
                const SizedBox(width: 8),
                _actionButton(colors, '+ Invoice', () => onIssueInvoice(s)),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _actionButton(AppColorsExtension colors, String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _planBadge(AppColorsExtension colors, String planName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        planName,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: colors.primaryLight,
        ),
      ),
    );
  }

  Widget _statusPill(AppColorsExtension colors, String status) {
    final upper = status.toUpperCase();
    final color = upper == 'ACTIVE'
        ? colors.success
        : upper == 'TRIAL'
        ? colors.primaryLight
        : upper == 'SUSPENDED'
        ? colors.accent
        : colors.error;
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
