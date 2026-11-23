import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/tenant_clinic_entity.dart';
import '../clinic_photo_avatar.dart';
import 'clinic_details_hero_actions.dart';
import 'clinic_details_status_badges.dart';

class ClinicDetailsHeroBanner extends StatelessWidget {
  final TenantClinicEntity clinic;
  final ValueChanged<TenantClinicEntity> onResendInvite;
  final ValueChanged<TenantClinicEntity> onToggleStatus;
  final ValueChanged<TenantClinicEntity> onDeleteClinic;

  const ClinicDetailsHeroBanner({
    super.key,
    required this.clinic,
    required this.onResendInvite,
    required this.onToggleStatus,
    required this.onDeleteClinic,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1050;
          final identity = Row(
            children: [
              ClinicPhotoAvatar(
                clinicId: clinic.id,
                name: clinic.name,
                size: 68,
                radius: 18,
                fontSize: 24,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.name,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (clinic.category.isNotEmpty)
                          ClinicDetailsStatusBadges.badge(
                            icon: Icons.local_hospital_outlined,
                            label: clinic.category,
                            bg: colors.badgeOpenBg,
                            fg: colors.badgeOpenText,
                          ),
                        if (clinic.city.isNotEmpty)
                          ClinicDetailsStatusBadges.badge(
                            icon: Icons.location_on_outlined,
                            label: clinic.city,
                            bg: colors.surfaceSecondary,
                            fg: colors.textMuted,
                          ),
                        ClinicDetailsStatusBadges.badge(
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

          final actions = ClinicDetailsHeroActions(
            clinic: clinic,
            isWide: isWide,
            onResendInvite: onResendInvite,
            onToggleStatus: onToggleStatus,
            onDeleteClinic: onDeleteClinic,
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
}
