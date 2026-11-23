import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/tenant_clinic_entity.dart';
import 'clinic_details_status_badges.dart';

class ClinicDetailsTopBar extends StatelessWidget {
  final TenantClinicEntity clinic;
  final VoidCallback onBack;
  final VoidCallback? onOpenDrawer;

  const ClinicDetailsTopBar({
    super.key,
    required this.clinic,
    required this.onBack,
    this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
              icon: Icon(
                Icons.menu_rounded,
                color: colors.textPrimary,
                size: 22,
              ),
              onPressed: () {
                if (onOpenDrawer != null) {
                  onOpenDrawer!();
                } else {
                  Scaffold.maybeOf(context)?.openDrawer();
                }
              },
            ),
            const SizedBox(width: 4),
          ],
          InkWell(
            onTap: onBack,
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
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Clinics Directory',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '/',
            style: GoogleFonts.inter(color: colors.textMuted, fontSize: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              clinic.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ClinicDetailsStatusBadges.statusPill(clinic.status, clinic.isInvited),
        ],
      ),
    );
  }
}
