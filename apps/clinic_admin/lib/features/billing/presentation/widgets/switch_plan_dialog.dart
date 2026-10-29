import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Confirm Subscription Change', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17)),
                    IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2563EB).withAlpha(100))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SELECTED TIER', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF60A5FA))),
                      const SizedBox(height: 4),
                      Text(targetTier.name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(
                        '₹$price / month • Billed ${isAnnual ? 'Annually' : 'Monthly'}',
                        style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF38BDF8), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your practice capacity limits will be adjusted immediately. The prorated difference will be charged to your primary Razorpay payment method.',
                  style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF94A3B8), height: 1.4),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Color(0xFF1E293B)),
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
                          backgroundColor: const Color(0xFF2563EB),
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
