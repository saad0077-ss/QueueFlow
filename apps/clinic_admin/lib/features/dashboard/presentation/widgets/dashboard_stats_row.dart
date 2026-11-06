import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/layout/clinic_breakpoints.dart';
import 'queue_stat_card.dart';

/// Key performance indicator cards on the clinic dashboard matching the web-admin design:
/// 1. Today's Appointments
/// 2. Customers Waiting (live queue)
/// 3. Customers Served today
/// 4. Checked In
class DashboardStatsRow extends StatelessWidget {
  final int waitingCount;
  final int todayAppointmentsCount;
  final int servedCount;
  final int checkedInCount;

  const DashboardStatsRow({
    super.key,
    required this.waitingCount,
    this.todayAppointmentsCount = 0,
    this.servedCount = 0,
    this.checkedInCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = <Widget>[
      // 1. Today's Appointments
      QueueStatCard(
        title: "Today's Appointments",
        value: '$todayAppointmentsCount',
        icon: Icons.calendar_month_outlined,
        iconColor: colors.primary,
        iconBgColor: colors.primaryTint,
      ),

      // 2. Customers Waiting
      QueueStatCard(
        title: 'Customers Waiting',
        value: '$waitingCount',
        icon: Icons.people_outline_rounded,
        iconColor: colors.accent,
        iconBgColor: colors.accentTint,
      ),

      // 3. Customers Served
      QueueStatCard(
        title: 'Customers Served',
        value: '$servedCount',
        icon: Icons.check_rounded,
        iconColor: colors.success,
        iconBgColor: colors.successTint,
      ),

      // 4. Checked in (at the clinic now)
      QueueStatCard(
        title: 'Checked In',
        value: '$checkedInCount',
        icon: Icons.how_to_reg_outlined,
        iconColor: colors.warning,
        iconBgColor: colors.warningTint,
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
