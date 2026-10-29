import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_ui_kit.dart';

/// Services are unlimited on every plan, so this only reports how many are active.
class ServiceCapacityQuotaCard extends StatelessWidget {
  final int currentCount;

  const ServiceCapacityQuotaCard({super.key, required this.currentCount});

  @override
  Widget build(BuildContext context) {
    final summary = '$currentCount Service${currentCount == 1 ? '' : 's'} Active (Unlimited Services)';
    const subText = 'All plans include unlimited clinical services.';
    const pillColor = ServiceColors.green;

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
        '$currentCount / ∞ ACTIVE',
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: pillColor,
        ),
      ),
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
                      pill,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 12),
                    pill,
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
