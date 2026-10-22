import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_ui_kit.dart';

class ServiceCapacityQuotaCard extends StatelessWidget {
  final int currentCount;
  final int limit;
  final bool isUnlimited;
  final String planName;
  final VoidCallback onUpgrade;

  const ServiceCapacityQuotaCard({
    super.key,
    required this.currentCount,
    required this.limit,
    required this.isUnlimited,
    required this.planName,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isLimit = !isUnlimited && currentCount >= limit;
    final summary = isUnlimited
        ? '$currentCount Services Active ($planName)'
        : '$currentCount of $limit Services Active ($planName)';
    final subText = isUnlimited
        ? 'Enterprise tier with unlimited clinical services and specialized consultation offerings.'
        : (limit == 1
              ? 'Solo practice plan covers 1 clinical service (1 service per practicing doctor).'
              : 'Multi-doctor plan covers up to $limit clinical services (1 service per doctor limit).');
    final pillColor = isLimit ? ServiceColors.amber : ServiceColors.green;

    final info = Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('📋', style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SERVICE PLAN CAPACITY',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: ServiceColors.muted,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                summary,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subText,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isUnlimited
            ? '$currentCount / ∞ ACTIVE'
            : '$currentCount / $limit ACTIVE',
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: pillColor,
        ),
      ),
    );

    final upgradeButton = ServiceOutlinedPill(
      label: 'Upgrade Service Limit →',
      onPressed: onUpgrade,
      height: 42,
      fontSize: 13,
    );

    // The blue accent strip follows the card's rounded left edge.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ServiceColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ServiceColors.border),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 20, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 640) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      info,
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [pill, upgradeButton],
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 12),
                    pill,
                    const SizedBox(width: 14),
                    upgradeButton,
                  ],
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(color: const Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }
}
