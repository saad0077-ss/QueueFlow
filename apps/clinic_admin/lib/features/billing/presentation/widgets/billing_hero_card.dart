import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/billing_dates.dart';
import '../../domain/entities/billing_plan_tier_entity.dart';
import '../../domain/entities/clinic_subscription_entity.dart';

class BillingHeroCard extends StatelessWidget {
  final ClinicSubscriptionEntity subscription;
  final BillingPlanTierEntity? currentTier;

  const BillingHeroCard({
    super.key,
    required this.subscription,
    required this.currentTier,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Reflects the clinic's actual paid cycle, not the pricing-tab preview.
    final isAnnual = subscription.billingCycle == 'annual';
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
      // Non-scrolling wrapper: absorbs sub-pixel rounding from IntrinsicHeight.
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
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
                    'Billed ${isAnnual ? 'Annually (20% Savings)' : 'Monthly'}',
                    style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: subscription.isPlanExpired ? colors.warningTint : colors.badgeOpenBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: subscription.isPlanExpired ? colors.warning : colors.success)),
                child: Text(subscription.isPlanExpired ? 'Expired' : 'Active', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: subscription.isPlanExpired ? colors.warning : colors.badgeOpenText)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹$price', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: colors.textPrimary)),
              const SizedBox(width: 6),
              Text(isAnnual ? '/ month (billed ₹${price * 12}/yr)' : '/ month', style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted)),
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
                if (subscription.periodEndAt != null) ...[
                  if (subscription.periodStartAt != null) ...[
                    _infoRow('Started:', formatBillingDate(subscription.periodStartAt!), colors.textPrimary, colors),
                    const SizedBox(height: 6),
                  ],
                  _infoRow('Expires:', formatBillingDate(subscription.periodEndAt!), colors.textPrimary, colors),
                  const SizedBox(height: 6),
                  _infoRow('Remaining:', formatRemaining(subscription.periodEndAt!), subscription.isPlanExpired ? colors.warning : colors.success, colors),
                  const SizedBox(height: 6),
                ],
                _infoRow('Payment Method:', 'Razorpay', colors.textPrimary, colors),
                const SizedBox(height: 6),
                _infoRow('Billing Contact:', subscription.billingContact.email, colors.textPrimary, colors),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (subscription.isPlanLocked)
            _notice(colors, Icons.lock_outline_rounded, colors.textMuted, colors.surfaceSecondary, colors.border,
                'Your plan cannot be changed until ${formatBillingDate(subscription.periodEndAt!)}. You can upgrade or switch plans once this subscription period ends.')
          else if (subscription.isPlanExpired)
            _notice(colors, Icons.check_circle_outline_rounded, colors.success, colors.successTint, colors.success,
                'Your subscription period has ended. You can now upgrade, switch or renew your plan below.'),
        ],
      )),
    );
  }

  Widget _notice(AppColorsExtension colors, IconData icon, Color iconColor, Color bg, Color border, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 11.5, height: 1.4, color: colors.textPrimary))),
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
