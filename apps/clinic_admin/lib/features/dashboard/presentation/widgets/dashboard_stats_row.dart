import 'package:flutter/material.dart';
import '../../../../core/layout/clinic_breakpoints.dart';
import 'queue_stat_card.dart';

/// Key performance indicator cards on the clinic dashboard.
/// Shows a single row of 4 on wide layouts and a 2x2 grid on narrow ones.
class DashboardStatsRow extends StatelessWidget {
  final int waitingCount;

  const DashboardStatsRow({
    super.key,
    required this.waitingCount,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      // 1. Today's Appointments
      const QueueStatCard(
        title: "Today's Appointments",
        value: '8',
        icon: Icons.assignment_outlined,
        iconColor: Color(0xFF38BDF8),
        iconBgColor: Color(0xFF172554),
      ),

      // 2. Customers Waiting
      QueueStatCard(
        title: 'Customers Waiting',
        value: '$waitingCount',
        icon: Icons.people_outline_rounded,
        iconColor: const Color(0xFF10B981),
        iconBgColor: const Color(0xFF064E3B),
      ),

      // 3. Customers Served
      const QueueStatCard(
        title: 'Customers Served',
        value: '22',
        icon: Icons.check_rounded,
        iconColor: Color(0xFF10B981),
        iconBgColor: Color(0xFF064E3B),
      ),

      // 4. Average Wait Time
      const QueueStatCard(
        title: 'Average Wait Time',
        value: '18 min',
        icon: Icons.access_time_rounded,
        iconColor: Color(0xFFF59E0B),
        iconBgColor: Color(0xFF451A03),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= ClinicBreakpoints.wideContent;
        final gap = isWide ? 16.0 : 12.0;

        if (isWide) return _row(cards, gap);
        return Column(
          children: [
            _row(cards.sublist(0, 2), gap),
            SizedBox(height: gap),
            _row(cards.sublist(2), gap),
          ],
        );
      },
    );
  }

  Widget _row(List<Widget> cards, double gap) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(child: cards[i]),
          ],
        ],
      ),
    );
  }
}
