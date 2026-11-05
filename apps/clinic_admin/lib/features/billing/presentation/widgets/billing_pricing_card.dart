import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/billing_plan_tier_entity.dart';

class BillingPricingCard extends StatelessWidget {
  final BillingPlanTierEntity tier;
  final bool isCurrent;
  /// True when this tier costs more than the clinic's current plan.
  final bool isUpgrade;
  final String activeCadence;
  final VoidCallback onSelectPlan;
  /// Fill the parent's height and pin the button to the bottom (equal-height desktop row).
  final bool expand;

  const BillingPricingCard({
    super.key,
    required this.tier,
    required this.isCurrent,
    required this.isUpgrade,
    required this.activeCadence,
    required this.onSelectPlan,
    this.expand = false,
  });

  /// Indian digit grouping: 2999 → 2,999 and 129999 → 1,29,999.
  static String formatInr(int value) {
    final s = value.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '${groups.join(',')},$last3';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isAnnual = activeCadence == 'annual';
    final price = isAnnual ? tier.annualPrice : tier.monthlyPrice;
    final capacity = tier.isUnlimited ? 'Unlimited' : '${tier.doctorLimit}';
    final borderColor = isCurrent ? colors.success : (tier.isPopular ? colors.primary : colors.border);

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(tier.name, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: colors.textPrimary)),
                ),
              ),
              if (tier.badge.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  tier.badge.toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: colors.primary, letterSpacing: 0.5),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(tier.tagline, style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted, height: 1.35)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('₹', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: colors.primaryLight)),
              Text(formatInr(price), style: GoogleFonts.jetBrainsMono(fontSize: 28, fontWeight: FontWeight.w800, color: colors.textPrimary)),
            ],
          ),
          Text(
            isAnnual ? '/ month • billed annually (₹${formatInr(price * 12)}/yr) + 18% GST' : '/ month • billed monthly + 18% GST',
            style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _chip(colors, Icons.medical_services_outlined, const Color(0xFF60A5FA), capacity, 'Doctor${tier.doctorLimit == 1 ? '' : 's'} Capacity'),
              _chip(colors, Icons.bolt_rounded, const Color(0xFFF97316), 'Unlimited', 'Live Queue & Patient Check-Ins'),
              _chip(colors, Icons.tv_rounded, const Color(0xFFA78BFA), 'Live', 'Token Calling & Waiting Display'),
            ],
          ),
          if (tier.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(tier.description, style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted, height: 1.45)),
          ],
          const SizedBox(height: 14),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 14),
          ...tier.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.badgeOpenBg,
                        border: Border.all(color: colors.success.withAlpha(140)),
                      ),
                      child: Icon(Icons.check_rounded, size: 11, color: colors.success),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: GoogleFonts.inter(fontSize: 11.5, color: colors.textPrimary, height: 1.3))),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          if (expand) const Spacer(),
          _actionButton(colors),
        ],
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isCurrent || tier.isPopular ? 1.5 : 1),
        boxShadow: [
          if (tier.isPopular && !isCurrent) BoxShadow(color: colors.primary.withAlpha(35), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top accent: green for the active plan, gradient for the popular one. Always
          // reserved so content lines up across cards.
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isCurrent ? colors.success : null,
              gradient: !isCurrent && tier.isPopular ? LinearGradient(colors: [colors.primary, colors.accent]) : null,
            ),
          ),
          if (expand) Expanded(child: body) else body,
        ],
      ),
    );
  }

  Widget _chip(AppColorsExtension colors, IconData icon, Color iconColor, String bold, String rest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Text.rich(
        TextSpan(children: [
          WidgetSpan(alignment: PlaceholderAlignment.middle, child: Icon(icon, size: 12, color: iconColor)),
          const TextSpan(text: '  '),
          TextSpan(text: '$bold ', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: colors.textPrimary)),
          TextSpan(text: rest, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: colors.textMuted)),
        ]),
      ),
    );
  }

  Widget _actionButton(AppColorsExtension colors) {
    final label = Text(
      isCurrent ? '✓ Current Active Plan' : '${isUpgrade ? 'Upgrade' : 'Switch'} to ${tier.name} →',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: isCurrent ? colors.badgeOpenText : Colors.white),
    );

    final BoxDecoration decoration;
    if (isCurrent) {
      decoration = BoxDecoration(
        color: colors.badgeOpenBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.success),
      );
    } else if (tier.isPopular) {
      decoration = BoxDecoration(
        gradient: LinearGradient(colors: [colors.primary, colors.accent]),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: colors.primary.withAlpha(60), blurRadius: 14, offset: const Offset(0, 6))],
      );
    } else {
      decoration = BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.primary),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCurrent ? null : onSelectPlan,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 40,
          decoration: decoration,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: isCurrent || tier.isPopular
                  ? label
                  : Text(
                      '${isUpgrade ? 'Upgrade' : 'Switch'} to ${tier.name} →',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: colors.primary),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
