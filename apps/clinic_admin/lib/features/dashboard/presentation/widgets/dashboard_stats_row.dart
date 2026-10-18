import 'package:flutter/material.dart';
import 'queue_stat_card.dart';

/// Row of 4 key performance indicator cards on the clinic dashboard.
class DashboardStatsRow extends StatelessWidget {
  final int waitingCount;

  const DashboardStatsRow({
    super.key,
    required this.waitingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Today's Appointments
        const QueueStatCard(
          title: "Today's Appointments",
          value: '8',
          icon: Icons.assignment_outlined,
          iconColor: Color(0xFF38BDF8),
          iconBgColor: Color(0xFF172554),
        ),
        const SizedBox(width: 16),

        // 2. Customers Waiting
        QueueStatCard(
          title: 'Customers Waiting',
          value: '$waitingCount',
          icon: Icons.people_outline_rounded,
          iconColor: const Color(0xFF10B981),
          iconBgColor: const Color(0xFF064E3B),
        ),
        const SizedBox(width: 16),

        // 3. Customers Served
        const QueueStatCard(
          title: 'Customers Served',
          value: '22',
          icon: Icons.check_rounded,
          iconColor: Color(0xFF10B981),
          iconBgColor: Color(0xFF064E3B),
        ),
        const SizedBox(width: 16),

        // 4. Average Wait Time
        const QueueStatCard(
          title: 'Average Wait Time',
          value: '18 min',
          icon: Icons.access_time_rounded,
          iconColor: Color(0xFFF59E0B),
          iconBgColor: Color(0xFF451A03),
        ),
      ],
    );
  }
}
