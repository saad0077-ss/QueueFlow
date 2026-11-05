import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/billing_plan_tier_entity.dart';

class SwitchPlanDialog {
  static void show(
    BuildContext context, {
    required BillingPlanTierEntity targetTier,
    required String activeCadence,
    required VoidCallback onConfirm,
  }) {
    final isAnnual = activeCadence == 'annual';
    final price = isAnnual ? targetTier.annualPrice : targetTier.monthlyPrice;
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Confirm Subscription Change', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: colors.textPrimary, fontSize: 17)),
                    IconButton(icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 18), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: colors.surfaceSecondary, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.primary.withAlpha(100))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SELECTED TIER', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: colors.primaryLight)),
                      const SizedBox(height: 4),
                      Text(targetTier.name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        '₹$price / month • Billed ${isAnnual ? 'Annually' : 'Monthly'}',
                        style: GoogleFonts.inter(fontSize: 12.5, color: colors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your practice capacity limits will be adjusted immediately. The prorated difference will be charged to your primary Razorpay payment method.',
                  style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Confirm & Upgrade'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
