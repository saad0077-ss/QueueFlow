import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_plan_tier_entity.dart';

class PlatformPlanTierCard extends StatelessWidget {
  final PlatformPlanTierEntity tier;
  final int enrolledClinics;
  final VoidCallback onEdit;

  /// Fill the parent's height and pin the edit button to the bottom (equal-height grid rows).
  final bool expand;

  const PlatformPlanTierCard({
    super.key,
    required this.tier,
    required this.enrolledClinics,
    required this.onEdit,
    this.expand = false,
  });

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
    final capacity = tier.isUnlimited ? 'Unlimited' : '${tier.doctorLimit}';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: tier.isPopular ? colors.primary : colors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Always reserve the strip so every card's content lines up.
          Container(
            height: 4,
            decoration: tier.isPopular
                ? const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
                    ),
                  )
                : null,
          ),
          _expandIf(
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 20, 26, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            tier.name,
                            style: GoogleFonts.inter(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (tier.badge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.primaryTint,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            tier.badge.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: colors.primaryLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tier.tagline,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: colors.textMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colors.primaryLight,
                        ),
                      ),
                      Text(
                        formatInr(tier.monthlyPrice),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '/ month (Annual: ₹${formatInr(tier.annualPrice)}/mo)',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Enrolled Practice Clinics:',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                        Text(
                          '$enrolledClinics Clinics',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: colors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(
                        colors,
                        Icons.medical_services_outlined,
                        const Color(0xFF60A5FA),
                        capacity,
                        'Doctor${tier.doctorLimit == 1 ? '' : 's'} Capacity',
                      ),
                      _chip(
                        colors,
                        Icons.bolt_rounded,
                        const Color(0xFFF97316),
                        'Unlimited',
                        'Live Queue & Patient Check-Ins',
                      ),
                      _chip(
                        colors,
                        Icons.tv_rounded,
                        const Color(0xFFA78BFA),
                        'Live',
                        'Token Calling & Waiting Display',
                      ),
                    ],
                  ),
                  if (tier.description.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text(
                      tier.description,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: colors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Divider(color: colors.border, height: 1),
                  const SizedBox(height: 18),
                  ...tier.features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF22C55E).withAlpha(30),
                              border: Border.all(
                                color: const Color(0xFF22C55E).withAlpha(140),
                              ),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (expand) const Spacer(),
                  _gradientButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandIf(Widget child) => expand ? Expanded(child: child) : child;

  Widget _chip(AppColorsExtension colors, IconData icon, Color iconColor, String bold, String rest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 8),
          Text(
            '$bold ',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          Text(
            rest,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withAlpha(60),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.settings_rounded,
                size: 15,
                color: Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                'Edit Plan, Price & Limits',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
