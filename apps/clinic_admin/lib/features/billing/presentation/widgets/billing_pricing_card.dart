import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static const _green = Color(0xFF10B981);
  static const _blue = Color(0xFF2563EB);
  static const _teal = Color(0xFF14B8A6);

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
    final isAnnual = activeCadence == 'annual';
    final price = isAnnual ? tier.annualPrice : tier.monthlyPrice;
    final capacity = tier.isUnlimited ? 'Unlimited' : '${tier.doctorLimit}';
    final borderColor = isCurrent ? _green : (tier.isPopular ? _blue : const Color(0xFF1E293B));

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
                  child: Text(tier.name, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              if (tier.badge.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  tier.badge.toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(tier.tagline, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), height: 1.35)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('₹', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF3B82F6))),
              Text(formatInr(price), style: GoogleFonts.jetBrainsMono(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
            ],
          ),
          Text(
            isAnnual ? '/ month • billed annually (₹${formatInr(price * 12)}/yr) + 18% GST' : '/ month • billed monthly + 18% GST',
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _chip(Icons.medical_services_outlined, const Color(0xFF60A5FA), capacity, 'Doctor${tier.doctorLimit == 1 ? '' : 's'} Capacity'),
              _chip(Icons.bolt_rounded, const Color(0xFFF97316), 'Unlimited', 'Live Queue & Patient Check-Ins'),
              _chip(Icons.tv_rounded, const Color(0xFFA78BFA), 'Live', 'Token Calling & Waiting Display'),
            ],
          ),
          if (tier.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(tier.description, style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8), height: 1.45)),
          ],
          const SizedBox(height: 14),
          const Divider(color: Color(0xFF1E293B), height: 1),
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
                        color: _green.withAlpha(30),
                        border: Border.all(color: _green.withAlpha(140)),
                      ),
                      child: const Icon(Icons.check_rounded, size: 11, color: _green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white, height: 1.3))),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          if (expand) const Spacer(),
          _actionButton(),
        ],
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isCurrent || tier.isPopular ? 1.5 : 1),
        boxShadow: [
          if (tier.isPopular && !isCurrent) BoxShadow(color: _blue.withAlpha(35), blurRadius: 20, offset: const Offset(0, 8)),
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
              color: isCurrent ? _green : null,
              gradient: !isCurrent && tier.isPopular ? const LinearGradient(colors: [_blue, _teal]) : null,
            ),
          ),
          if (expand) Expanded(child: body) else body,
        ],
      ),
    );
  }

  Widget _chip(IconData icon, Color iconColor, String bold, String rest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withAlpha(160),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334E7A)),
      ),
      child: Text.rich(
        TextSpan(children: [
          WidgetSpan(alignment: PlaceholderAlignment.middle, child: Icon(icon, size: 12, color: iconColor)),
          const TextSpan(text: '  '),
          TextSpan(text: '$bold ', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white)),
          TextSpan(text: rest, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1))),
        ]),
      ),
    );
  }

  Widget _actionButton() {
    final label = Text(
      isCurrent ? '✓ Current Active Plan' : '${isUpgrade ? 'Upgrade' : 'Switch'} to ${tier.name} →',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: isCurrent ? const Color(0xFF34D399) : Colors.white),
    );

    final BoxDecoration decoration;
    if (isCurrent) {
      decoration = BoxDecoration(
        color: const Color(0xFF065F46).withAlpha(45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF059669)),
      );
    } else if (tier.isPopular) {
      decoration = BoxDecoration(
        gradient: const LinearGradient(colors: [_blue, _teal]),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: _blue.withAlpha(60), blurRadius: 14, offset: const Offset(0, 6))],
      );
    } else {
      decoration = BoxDecoration(
        color: const Color(0xFF172554).withAlpha(140),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334E7A)),
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
          child: Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: label)),
        ),
      ),
    );
  }
}
