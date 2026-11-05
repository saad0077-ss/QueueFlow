import 'package:flutter/material.dart';

import '../../../../core/layout/clinic_breakpoints.dart';
import 'appointment_trend_card.dart';
import 'now_serving_card.dart';
import 'popular_services_card.dart';
import 'quick_actions_card.dart';
import 'upcoming_appointments_card.dart';

/// The body of the clinic dashboard.
/// Wide: left column has upcoming appointments + trend chart, right column
/// has now serving + quick actions + popular services.
/// Narrow: a single column with the live queue controls first.
class DashboardMainColumns extends StatelessWidget {
  final String currentToken;
  final int waitingCount;
  final VoidCallback onCallNext;
  final VoidCallback onViewQueue;
  final VoidCallback onAddWalkIn;
  final VoidCallback onCreateAppointment;
  final VoidCallback onTogglePauseQueue;
  final bool isQueuePaused;
  final VoidCallback? onViewAllAppointments;

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
    this.onViewAllAppointments,
  });

  @override
  Widget build(BuildContext context) {
    final nowServing = NowServingCard(
      currentToken: currentToken,
      waitingCount: waitingCount,
      onCallNext: onCallNext,
      onViewQueue: onViewQueue,
    );
    final quickActions = QuickActionsCard(
      onAddWalkIn: onAddWalkIn,
      onCreateAppointment: onCreateAppointment,
      onTogglePauseQueue: onTogglePauseQueue,
      isQueuePaused: isQueuePaused,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < ClinicBreakpoints.wideContent) {
          return Column(
            children: [
              nowServing,
              const SizedBox(height: 16),
              quickActions,
              const SizedBox(height: 16),
              UpcomingAppointmentsCard(onViewAll: onViewAllAppointments),
              const SizedBox(height: 16),
              const AppointmentTrendCard(),
              const SizedBox(height: 16),
              const PopularServicesCard(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (flex 65)
            Expanded(
              flex: 65,
              child: Column(
                children: [
                  UpcomingAppointmentsCard(onViewAll: onViewAllAppointments),
                  const SizedBox(height: 20),
                  const AppointmentTrendCard(),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Right Column (flex 35)
            Expanded(
              flex: 35,
              child: Column(
                children: [
                  nowServing,
                  const SizedBox(height: 16),
                  quickActions,
                  const SizedBox(height: 16),
                  const PopularServicesCard(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
