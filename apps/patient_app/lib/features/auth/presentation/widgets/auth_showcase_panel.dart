import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'auth_showcase_feature_item.dart';
import 'auth_showcase_header.dart';

/// Reusable left-side showcase panel for Laptop viewports on Auth screens.
class AuthShowcasePanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? highlightTag;

  const AuthShowcasePanel({
    super.key,
    required this.title,
    required this.subtitle,
    this.highlightTag,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                  colors.primary.withValues(alpha: 0.15),
                ]
              : [
                  const Color(0xFF0F2042),
                  const Color(0xFF1A365D),
                  const Color(0xFF2563EB),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthShowcaseHeader(),
          const Spacer(flex: 3),
          if (highlightTag != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF38BDF8),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    highlightTag!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF38BDF8),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.25,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFCBD5E1),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),
          const AuthShowcaseFeatureItem(
            icon: Icons.radar_rounded,
            title: 'Live Digital Queue Radar',
            description:
                'Watch your position advance in real-time from anywhere.',
          ),
          const SizedBox(height: 18),
          const AuthShowcaseFeatureItem(
            icon: Icons.event_available_rounded,
            title: 'Direct Clinic & Doctor Booking',
            description:
                'Lock in appointment slots instantly without wait times.',
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}
