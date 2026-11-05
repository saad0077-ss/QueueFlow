import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import 'clinic_details_actions.dart';
import 'clinic_details_info_card.dart';
import 'edit_clinic_modal.dart';

class ClinicDetailsModal {
  static void show(
    BuildContext context,
    TenantClinicEntity clinic, {
    required VoidCallback onToggleSuspension,
    required VoidCallback onChangeSubscription,
    VoidCallback? onOpenFullScreen,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        final colors = ctx.colors;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: 550,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 16)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(ctx, clinic, onOpenFullScreen, colors),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      StatMetricBox(label: 'PLAN TIER', value: clinic.planName, color: colors.primaryLight),
                      const SizedBox(width: 8),
                      StatMetricBox(label: 'LIVE QUEUE', value: clinic.queueStatus, color: colors.success),
                      const SizedBox(width: 8),
                      StatMetricBox(
                        label: 'PLATFORM STATUS',
                        value: clinic.isInvited ? 'INVITED (Pending)' : clinic.status,
                        color: clinic.isInvited
                            ? colors.primaryLight
                            : (clinic.isActive ? colors.success : colors.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FacilityInfoCard(clinic: clinic),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('🩺', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text('PRACTICING DOCTORS ON ROSTER', style: GoogleFonts.inter(color: colors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
                    ],
                  ),
                  for (final doc in clinic.doctors.take(2)) DoctorRosterTile(doc: doc),
                  const SizedBox(height: 18),
                  ClinicDetailsActionButtons(
                    isInvited: clinic.isInvited,
                    isActive: clinic.isActive,
                    onToggleSuspension: onToggleSuspension,
                    onChangeSubscription: onChangeSubscription,
                    onDone: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildHeader(BuildContext ctx, TenantClinicEntity c, VoidCallback? onOpenFullScreen, AppColorsExtension colors) => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(c.name.length >= 2 ? c.name.substring(0, 2).toUpperCase() : 'CL', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: colors.textPrimary, fontSize: 16.5)),
            const SizedBox(height: 3),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: colors.badgeOpenBg, borderRadius: BorderRadius.circular(4), border: Border.all(color: colors.success.withValues(alpha: 0.3))),
                  child: Text(c.category, style: GoogleFonts.inter(color: colors.badgeOpenText, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: colors.warningTint, borderRadius: BorderRadius.circular(4), border: Border.all(color: colors.warning.withValues(alpha: 0.3))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 11, color: colors.ratingGold),
                      const SizedBox(width: 2),
                      Text('${c.rating}', style: GoogleFonts.inter(color: colors.ratingGold, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${c.city}, Kerala', style: GoogleFonts.inter(color: colors.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      InkWell(
        onTap: () {
          Navigator.pop(ctx);
          EditClinicModal.show(ctx, c);
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: colors.surfaceSecondary, borderRadius: BorderRadius.circular(6)),
          child: Icon(Icons.edit_note_rounded, size: 14, color: colors.primaryLight),
        ),
      ),
      const SizedBox(width: 8),
      if (onOpenFullScreen != null) ...[
        InkWell(
          onTap: () {
            Navigator.pop(ctx);
            onOpenFullScreen();
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: colors.surfaceSecondary, borderRadius: BorderRadius.circular(6)),
            child: Icon(Icons.open_in_new_rounded, size: 14, color: colors.primaryLight),
          ),
        ),
        const SizedBox(width: 8),
      ],
      InkWell(
        onTap: () => Navigator.pop(ctx),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: colors.surfaceSecondary, borderRadius: BorderRadius.circular(6)),
          child: Icon(Icons.close_rounded, size: 14, color: colors.textMuted),
        ),
      ),
    ],
  );
}
