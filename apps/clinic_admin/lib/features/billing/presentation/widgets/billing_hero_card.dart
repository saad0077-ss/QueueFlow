import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/billing_plan_tier_entity.dart';
import '../../domain/entities/clinic_subscription_entity.dart';

class BillingHeroCard extends StatelessWidget {
  final ClinicSubscriptionEntity subscription;
  final BillingPlanTierEntity? currentTier;
  final String activeCadence;
  final VoidCallback onToggleCadence;
  final VoidCallback onUpgrade;

  const BillingHeroCard({
    super.key,
    required this.subscription,
    required this.currentTier,
    required this.activeCadence,
    required this.onToggleCadence,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isAnnual = activeCadence == 'annual';
    final price = currentTier != null
        ? (isAnnual ? currentTier!.annualPrice : currentTier!.monthlyPrice)
        : (isAnnual ? 799 : 999);
    final annualSavings = currentTier != null ? (currentTier!.monthlyPrice - currentTier!.annualPrice) * 12 : 2400;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: colors.primaryTint, borderRadius: BorderRadius.circular(6)),
                    child: Text('CURRENT PLAN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: colors.primaryLight)),
                  ),
                  const SizedBox(height: 6),
                  Text(subscription.planName, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    'Billed ${isAnnual ? 'Annually (20% Savings)' : 'Monthly'} • Renews ${subscription.currentPeriodEnd}',
                    style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: colors.badgeOpenBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: colors.success)),
                child: Text('Active', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: colors.badgeOpenText)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('₹$price', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: colors.textPrimary)),
              const SizedBox(width: 6),
              Text(isAnnual ? '/ month (billed ₹${price * 12}/yr)' : '/ month + GST', style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isAnnual ? '🎉 You are saving ₹$annualSavings/yr with Annual Billing!' : '⚡ Save 20% by switching to Annual Billing (₹${currentTier?.annualPrice ?? 799}/mo)',
            style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: colors.success),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colors.surfaceSecondary, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
            child: Column(
              children: [
                _infoRow('Payment Method:', subscription.paymentMethod.brand, colors.textPrimary, colors),
                const SizedBox(height: 6),
                _infoRow('Auto-Renewal:', subscription.autoRenew ? 'Enabled' : 'Paused', colors.success, colors),
                const SizedBox(height: 6),
                _infoRow('Billing Contact:', subscription.billingContact.email, colors.textPrimary, colors),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onToggleCadence,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(isAnnual ? 'Switch to Monthly' : 'Switch to Annual (Save 20%)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Upgrade Tier', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color valColor, AppColorsExtension colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted)),
        const SizedBox(width: 12),
        // Long values (e.g. billing emails) shrink instead of overflowing narrow cards.
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: valColor),
          ),
        ),
      ],
    );
  }
}
