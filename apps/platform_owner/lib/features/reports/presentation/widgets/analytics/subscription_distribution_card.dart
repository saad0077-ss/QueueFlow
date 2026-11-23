import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/platform_report_entity.dart';
import 'doctor_utilization_box.dart';
import 'subscription_tier_info_box.dart';

class SubscriptionDistributionCard extends StatelessWidget {
  final PlatformReportEntity report;

  const SubscriptionDistributionCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Tiers & Doctor Capacity',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enrollment across the 3 doctor capacity tiers',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${report.connectedClinics} CLINICS ENROLLED',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SubscriptionTierInfoBox(
            iconEmoji: '👑',
            tierTitle: 'Unlimited Doctors Plan',
            countAndPercentage: '${report.unlimitedTierCount} Clinics (33.3%)',
            priceMonthly: '₹6,999/mo',
            priceColor: const Color(0xFF0284C7),
            clinicNames: 'CityCare General Clinic, Metro Diagnostics Center',
          ),
          const SizedBox(height: 12),
          SubscriptionTierInfoBox(
            iconEmoji: '🏥',
            tierTitle: 'Multi-Doctor Clinic Plan',
            countAndPercentage: '${report.multiTierCount} Clinics (50.0%)',
            priceMonthly: '₹2,999/mo',
            priceColor: const Color(0xFF10B981),
            clinicNames: 'Sunrise Health Clinic, Smile Dental Care, Wellness Skin Studio',
          ),
          const SizedBox(height: 12),
          SubscriptionTierInfoBox(
            iconEmoji: '👤',
            tierTitle: 'Solo Doctor Plan',
            countAndPercentage: '${report.soloTierCount} Clinic (16.7%)',
            priceMonthly: '₹999/mo',
            priceColor: const Color(0xFFF59E0B),
            clinicNames: 'Kochi Family Clinic',
          ),
          const SizedBox(height: 12),
          DoctorUtilizationBox(
            activeDoctors: report.activeDoctors,
            totalSlots: report.totalDoctorSlots,
          ),
        ],
      ),
    );
  }
}
