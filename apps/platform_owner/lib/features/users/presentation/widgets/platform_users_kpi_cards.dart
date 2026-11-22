import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/platform_user_entity.dart';

class PlatformUsersKpiCards extends StatelessWidget {
  final List<PlatformUserEntity> users;

  const PlatformUsersKpiCards({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalUsers = users.length;
    final inQueueUsers = users.where((u) => u.activeQueueToken != null && u.activeQueueToken!.isNotEmpty).length;
    final verifiedUsers = users.where((u) => u.isVerified).length;
    final verifiedPercent = totalUsers > 0 ? ((verifiedUsers / totalUsers) * 100).toInt() : 100;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;

        final cards = [
          _buildKpiCard(
            colors: colors,
            tag: 'REGISTRY ACTIVE',
            label: 'Total Registered Users',
            value: '$totalUsers',
            trend: 'Live Database',
            subtext: 'Active accounts',
            icon: Icons.people_alt_rounded,
            themeColor: const Color(0xFF0072FF),
            isPulse: false,
          ),
          _buildKpiCard(
            colors: colors,
            tag: 'LIVE QUEUE',
            label: 'Patients in Live Queue',
            value: '$inQueueUsers',
            trend: 'Waiting & Called',
            subtext: 'Real-time token triage',
            icon: Icons.confirmation_number_rounded,
            themeColor: const Color(0xFFF59E0B),
            isPulse: inQueueUsers > 0,
          ),
          _buildKpiCard(
            colors: colors,
            tag: 'ACCOUNT HEALTH',
            label: 'Verified User Profiles',
            value: '$verifiedUsers',
            trend: '$verifiedPercent% Compliance',
            subtext: 'OTP & phone verified',
            icon: Icons.verified_user_rounded,
            themeColor: const Color(0xFF10B981),
            isPulse: false,
          ),
        ];

        if (isMobile) {
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i < cards.length - 1) const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required AppColorsExtension colors,
    required String tag,
    required String label,
    required String value,
    required String trend,
    required String subtext,
    required IconData icon,
    required Color themeColor,
    required bool isPulse,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: themeColor.withAlpha(35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPulse) ...[
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: themeColor.withAlpha(120),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                        Text(
                          tag,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(label, style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted)),
                ],
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: themeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: themeColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: themeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: themeColor),
                ),
              ),
              const SizedBox(width: 6),
              Text(subtext, style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
