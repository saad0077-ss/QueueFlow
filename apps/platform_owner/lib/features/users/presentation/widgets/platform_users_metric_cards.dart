import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/platform_user_entity.dart';

class PlatformUsersMetricCards extends StatelessWidget {
  final List<PlatformUserEntity> users;

  const PlatformUsersMetricCards({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalUsers = users.length;
    final inQueueUsers = users
        .where(
          (u) => u.activeQueueToken != null && u.activeQueueToken!.isNotEmpty,
        )
        .length;
    final verifiedUsers = users
        .where((u) => u.isVerified && u.status.toLowerCase() != 'suspended')
        .length;
    final verifiedPercent = totalUsers > 0
        ? ((verifiedUsers / totalUsers) * 100).toInt()
        : 100;

    final cards = [
      AppMetricCard(
        tag: 'REGISTRY ACTIVE',
        tagColor: const Color(0xFF38BDF8),
        label: 'Total Registered Users',
        value: '$totalUsers',
        icon: Icons.people_alt_rounded,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Live patient registry',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'LIVE QUEUE',
        tagColor: const Color(0xFFF59E0B),
        hasDot: inQueueUsers > 0,
        dotColor: const Color(0xFFF59E0B),
        label: 'Patients in Live Queue',
        value: '$inQueueUsers',
        icon: Icons.confirmation_number_rounded,
        iconColor: const Color(0xFFFBBF24),
        iconBgColor: const Color(0xFF78350F).withValues(alpha: 0.35),
        borderColor: const Color(0xFFB45309).withValues(alpha: 0.4),
        bottomWidget: Text(
          inQueueUsers > 0 ? 'Active in waiting triage' : 'None in queue',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'ACCOUNT HEALTH',
        tagColor: const Color(0xFF10B981),
        label: 'Verified User Profiles',
        value: '$verifiedUsers',
        icon: Icons.verified_user_rounded,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Text(
          '$verifiedPercent% compliance (OTP verified)',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final colCount = w >= 900 ? 3 : (w >= 560 ? 2 : 1);
        const spacing = 12.0;
        final itemWidth = (w - ((colCount - 1) * spacing)) / colCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((c) => SizedBox(width: itemWidth, child: c))
              .toList(),
        );
      },
    );
  }
}
