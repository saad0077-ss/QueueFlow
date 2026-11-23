import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/tenant_clinic_entity.dart';
import 'clinic_details_common_widgets.dart';
import 'clinic_details_dialog_helper.dart';

class ClinicDetailsAdministratorCard extends StatelessWidget {
  final TenantClinicEntity clinic;
  final ValueChanged<TenantClinicEntity> onResendInvite;

  const ClinicDetailsAdministratorCard({
    super.key,
    required this.clinic,
    required this.onResendInvite,
  });

  @override
  Widget build(BuildContext context) {
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
          ClinicDetailsCommonWidgets.sectionHeader(
            colors,
            icon: Icons.admin_panel_settings_outlined,
            color: const Color(0xFF38BDF8),
            title: 'Clinic Administrator Profile',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.primary,
                child: Text(
                  clinic.adminName.isNotEmpty
                      ? clinic.adminName.substring(0, 1).toUpperCase()
                      : 'A',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.adminName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Clinic Administrator',
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
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: colors.primaryLight,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    clinic.adminEmail,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                ClinicDetailsCommonWidgets.copyButton(
                  colors,
                  () => ClinicDetailsDialogHelper.copyToClipboard(
                    context,
                    clinic.adminEmail,
                    'Email Address',
                  ),
                  tooltip: 'Copy Email',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildActivationStatusBox(colors),
        ],
      ),
    );
  }

  Widget _buildActivationStatusBox(AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: clinic.isInvited
            ? colors.primaryTint
            : (clinic.isActive ? colors.badgeOpenBg : colors.errorTint),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: clinic.isInvited
              ? colors.primaryLight.withValues(alpha: 0.4)
              : (clinic.isActive
                    ? colors.success.withValues(alpha: 0.4)
                    : colors.error.withValues(alpha: 0.4)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                clinic.isInvited
                    ? Icons.hourglass_top_rounded
                    : (clinic.isActive
                          ? Icons.verified_rounded
                          : Icons.block_rounded),
                size: 16,
                color: clinic.isInvited
                    ? colors.primaryLight
                    : (clinic.isActive ? colors.badgeOpenText : colors.error),
              ),
              const SizedBox(width: 8),
              Text(
                clinic.isInvited
                    ? 'Invitation Pending Activation'
                    : (clinic.isActive
                          ? 'Account Active & Verified'
                          : 'Practice Suspended'),
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: clinic.isInvited
                      ? colors.primaryLight
                      : (clinic.isActive ? colors.badgeOpenText : colors.error),
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
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: colors.textPrimary,
              height: 1.35,
            ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 14),
                label: Text(
                  'Resend Invite & Copy Link',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => onResendInvite(clinic),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
