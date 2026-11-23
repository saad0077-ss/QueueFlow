import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/tenant_clinic_entity.dart';
import '../edit_clinic_modal.dart';
import '../manage_subscription_modal.dart';
import 'clinic_details_status_badges.dart';

class ClinicDetailsHeroActions extends StatelessWidget {
  final TenantClinicEntity clinic;
  final bool isWide;
  final ValueChanged<TenantClinicEntity> onResendInvite;
  final ValueChanged<TenantClinicEntity> onToggleStatus;
  final ValueChanged<TenantClinicEntity> onDeleteClinic;

  const ClinicDetailsHeroActions({
    super.key,
    required this.clinic,
    required this.isWide,
    required this.onResendInvite,
    required this.onToggleStatus,
    required this.onDeleteClinic,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: isWide ? WrapAlignment.end : WrapAlignment.start,
      children: [
        ClinicDetailsStatusBadges.headerActionButton(
          colors,
          icon: Icons.edit_note_rounded,
          label: 'Edit Clinic Details',
          bg: colors.surfaceSecondary,
          fg: colors.primaryLight,
          onTap: () => EditClinicModal.show(context, clinic),
        ),
        ClinicDetailsStatusBadges.headerActionButton(
          colors,
          icon: Icons.tune_rounded,
          label: 'Manage Subscription',
          bg: colors.surfaceSecondary,
          fg: colors.primaryLight,
          onTap: () => ManageSubscriptionModal.show(context, clinic),
        ),
        if (clinic.isInvited)
          ClinicDetailsStatusBadges.headerActionButton(
            colors,
            icon: Icons.send_rounded,
            label: 'Resend Invitation Email',
            bg: colors.primaryTint,
            fg: colors.primaryLight,
            onTap: () => onResendInvite(clinic),
          )
        else
          ClinicDetailsStatusBadges.headerActionButton(
            colors,
            icon: clinic.isActive
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            label: clinic.isActive
                ? 'Pause Clinic Practice'
                : 'Activate Clinic Practice',
            bg: clinic.isActive ? colors.warningTint : colors.badgeOpenBg,
            fg: clinic.isActive ? colors.warning : colors.badgeOpenText,
            onTap: () => onToggleStatus(clinic),
          ),
        ClinicDetailsStatusBadges.headerActionButton(
          colors,
          icon: Icons.delete_outline_rounded,
          label: 'Delete Clinic Facility',
          bg: colors.errorTint,
          fg: colors.error,
          onTap: () => onDeleteClinic(clinic),
        ),
      ],
    );
  }
}
