import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../dashboard/presentation/widgets/clinic_photo_avatar.dart';
import '../../domain/entities/platform_tenant_subscription_entity.dart';

class PlatformTenantSubscriptionRow extends StatelessWidget {
  final int index;
  final PlatformTenantSubscriptionEntity subscription;
  final ValueChanged<PlatformTenantSubscriptionEntity> onManageSubscription;
  final ValueChanged<PlatformTenantSubscriptionEntity> onIssueInvoice;

  const PlatformTenantSubscriptionRow({
    super.key,
    required this.index,
    required this.subscription,
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
    final s = subscription;
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
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colors.textPrimary,
                  ),
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
                _btn(colors, 'Change Plan', () => onManageSubscription(s)),
                const SizedBox(width: 8),
                _btn(colors, '+ Invoice', () => onIssueInvoice(s)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(AppColorsExtension colors, String label, VoidCallback onTap) {
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
