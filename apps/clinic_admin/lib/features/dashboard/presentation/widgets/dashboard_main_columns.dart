import 'package:flutter/material.dart';

import 'appointment_trend_card.dart';
import 'now_serving_card.dart';
import 'popular_services_card.dart';
import 'quick_actions_card.dart';
import 'upcoming_appointments_card.dart';

/// The two-column body of the clinic dashboard.
/// Left column: Upcoming appointments + Trend chart.
/// Right column: Now serving card + Quick actions + Popular services.
class DashboardMainColumns extends StatelessWidget {
  final String currentToken;
  final int waitingCount;
  final VoidCallback onCallNext;
  final VoidCallback onViewQueue;
  final VoidCallback onAddWalkIn;
  final VoidCallback onCreateAppointment;
  final VoidCallback onTogglePauseQueue;
  final bool isQueuePaused;

  const DashboardMainColumns({
    super.key,
    required this.currentToken,
    required this.waitingCount,
    required this.onCallNext,
    required this.onViewQueue,
    required this.onAddWalkIn,
    required this.onCreateAppointment,
    required this.onTogglePauseQueue,
    required this.isQueuePaused,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (flex 65)
        Expanded(
          flex: 65,
          child: Column(
            children: const [
              UpcomingAppointmentsCard(),
              SizedBox(height: 20),
              AppointmentTrendCard(),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Right Column (flex 35)
        Expanded(
          flex: 35,
          child: Column(
            children: [
              NowServingCard(
                currentToken: currentToken,
                waitingCount: waitingCount,
                onCallNext: onCallNext,
                onViewQueue: onViewQueue,
              ),
              const SizedBox(height: 16),
              QuickActionsCard(
                onAddWalkIn: onAddWalkIn,
                onCreateAppointment: onCreateAppointment,
                onTogglePauseQueue: onTogglePauseQueue,
                isQueuePaused: isQueuePaused,
              ),
              const SizedBox(height: 16),
              const PopularServicesCard(),
            ],
          ),
        ),
      ],
    );
  }
}
