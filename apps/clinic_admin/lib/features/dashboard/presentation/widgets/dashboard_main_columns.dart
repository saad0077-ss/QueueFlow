import 'package:flutter/material.dart';
import '../../../../core/layout/clinic_breakpoints.dart';
import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../domain/entities/dashboard_overview.dart';
import 'appointment_trend_card.dart';
import 'clinic_departments_hub_card.dart';
import 'now_serving_card.dart';
import 'popular_services_card.dart';
import 'quick_actions_card.dart';
import 'upcoming_appointments_card.dart';

/// The main content sections of the Clinic Dashboard matching the web-admin structure:
/// 1. Clinic Departments & Clinical Triage Hub Card
/// 2. Middle 2-Column Grid:
///    - Left (2fr): Upcoming Appointments Table
///    - Right (1fr): Now Serving Live Widget + Quick Actions Card
/// 3. Bottom 2-Column Grid:
///    - Left (1fr): Appointment Volume Trend (7 days)
///    - Right (1fr): Popular Services
class DashboardMainColumns extends StatelessWidget {
  final DashboardOverview overview;
  final String currentToken;
  final int waitingCount;
  final VoidCallback onCallNext;
  final VoidCallback onViewQueue;
  final VoidCallback onAddWalkIn;
  final VoidCallback onCreateAppointment;
  final VoidCallback onTogglePauseQueue;
  final bool isQueuePaused;
  final VoidCallback? onViewAllAppointments;
  final ValueChanged<ClinicAppointmentEntity>? onSelectAppointment;
  final VoidCallback? onNavigateToServices;

  const DashboardMainColumns({
    super.key,
    required this.overview,
    required this.currentToken,
    required this.waitingCount,
    required this.onCallNext,
    required this.onViewQueue,
    required this.onAddWalkIn,
    required this.onCreateAppointment,
    required this.onTogglePauseQueue,
    required this.isQueuePaused,
    this.onViewAllAppointments,
    this.onSelectAppointment,
    this.onNavigateToServices,
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

    final upcomingCard = UpcomingAppointmentsCard(
      appointments: overview.upcoming,
      onViewAll: onViewAllAppointments,
      onSelectAppointment: onSelectAppointment,
    );

    final deptsHub = ClinicDepartmentsHubCard(
      departments: overview.departments,
      onNavigateToServices: onNavigateToServices,
      onNavigateToAppointments: onViewAllAppointments,
    );

    final trendCard = AppointmentTrendCard(data: overview.trend);
    final popularCard = PopularServicesCard(
      services: [
        for (final s in overview.popularServices)
          PopularServiceItem(
            name: s.name,
            department: s.department,
            count: s.count,
            percentage: s.percentage,
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= ClinicBreakpoints.wideContent;

        if (!isWide) {
          // Narrow / Mobile Layout: clean linear flow
          return Column(
            children: [
              nowServing,
              const SizedBox(height: 18),
              quickActions,
              const SizedBox(height: 18),
              deptsHub,
              const SizedBox(height: 18),
              upcomingCard,
              const SizedBox(height: 18),
              trendCard,
              const SizedBox(height: 18),
              popularCard,
            ],
          );
        }

        // Wide Layout matching web-admin grid structure
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Clinical Departments & Specialties Hub
            deptsHub,
            const SizedBox(height: 22),

            // 2. Middle 2-Column Grid (Upcoming Appts + Now Serving / Actions)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Upcoming Appointments (flex 65 / 2fr)
                Expanded(
                  flex: 65,
                  child: upcomingCard,
                ),
                const SizedBox(width: 22),
                // Right Column: Now Serving & Quick Actions (flex 35 / 1fr)
                Expanded(
                  flex: 35,
                  child: Column(
                    children: [
                      nowServing,
                      const SizedBox(height: 18),
                      quickActions,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 3. Bottom 2-Column Grid (Trend + Popular Services)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: trendCard),
                  const SizedBox(width: 22),
                  Expanded(child: popularCard),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
