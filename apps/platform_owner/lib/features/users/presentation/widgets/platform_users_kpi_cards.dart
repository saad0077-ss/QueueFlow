import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_user_entity.dart';

class PlatformUsersKpiCards extends StatefulWidget {
  final List<PlatformUserEntity> users;

  const PlatformUsersKpiCards({super.key, required this.users});

  @override
  State<PlatformUsersKpiCards> createState() => _PlatformUsersKpiCardsState();
}

class _PlatformUsersKpiCardsState extends State<PlatformUsersKpiCards>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalUsers = widget.users.length;
    final inQueueUsers = widget.users
        .where(
          (u) => u.activeQueueToken != null && u.activeQueueToken!.isNotEmpty,
        )
        .length;
    final verifiedUsers = widget.users
        .where((u) => u.isVerified && u.status.toLowerCase() != 'suspended')
        .length;
    final verifiedPercent = totalUsers > 0
        ? ((verifiedUsers / totalUsers) * 100).toInt()
        : 100;

    const clinicTrendLabel = 'Live Patient Registry';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;

        final cards = [
          _buildKpiCard(
            colors: colors,
            tag: 'REGISTRY ACTIVE',
            label: 'Total Registered Users',
            value: '$totalUsers',
            trendPill: clinicTrendLabel,
            trendColor: const Color(0xFF10B981),
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
            trendPill: 'Waiting & Called',
            trendColor: const Color(0xFFF59E0B),
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
            trendPill: '$verifiedPercent% Compliance',
            trendColor: const Color(0xFF10B981),
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
    required String trendPill,
    required Color trendColor,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isPulse)
                        FadeTransition(
                          opacity: _pulseController,
                          child: Container(
                            width: 6.5,
                            height: 6.5,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: themeColor.withAlpha(160),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      Text(
                        tag,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: themeColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: themeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: themeColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: trendColor.withAlpha(22),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  trendPill,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: trendColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                subtext,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
