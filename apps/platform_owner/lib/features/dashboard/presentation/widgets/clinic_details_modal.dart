import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import 'clinic_details_actions.dart';
import 'clinic_details_info_card.dart';

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
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1527),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E293B)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.65), blurRadius: 40, offset: const Offset(0, 16)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(ctx, clinic, onOpenFullScreen),
                const SizedBox(height: 16),
                Row(
                  children: [
                    StatMetricBox(label: 'PLAN TIER', value: clinic.planName, color: const Color(0xFF38BDF8)),
                    const SizedBox(width: 8),
                    StatMetricBox(label: 'LIVE QUEUE', value: clinic.queueStatus, color: const Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    StatMetricBox(
                      label: 'PLATFORM STATUS',
                      value: clinic.isInvited ? 'INVITED (Pending)' : clinic.status,
                      color: clinic.isInvited
                          ? const Color(0xFF60A5FA)
                          : (clinic.isActive ? const Color(0xFF10B981) : Colors.redAccent),
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
                    Text('PRACTICING DOCTORS ON ROSTER', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
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
      ),
    );
  }

  static Widget _buildHeader(BuildContext ctx, TenantClinicEntity c, VoidCallback? onOpenFullScreen) => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(c.name.length >= 2 ? c.name.substring(0, 2).toUpperCase() : 'CL', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16.5)),
            const SizedBox(height: 3),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF064E3B).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3))),
                  child: Text(c.category, style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF78350F).withValues(alpha: 0.35), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 11, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 2),
                      Text('${c.rating}', style: GoogleFonts.inter(color: const Color(0xFFFBBF24), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${c.city}, Kerala', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      if (onOpenFullScreen != null) ...[
        InkWell(
          onTap: () {
            Navigator.pop(ctx);
            onOpenFullScreen();
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.open_in_new_rounded, size: 14, color: Color(0xFF38BDF8)),
          ),
        ),
        const SizedBox(width: 8),
      ],
      InkWell(
        onTap: () => Navigator.pop(ctx),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF94A3B8)),
        ),
      ),
    ],
  );
}
