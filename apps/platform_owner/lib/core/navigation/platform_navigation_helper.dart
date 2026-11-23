import 'package:flutter/material.dart';

import '../../features/billing/presentation/pages/platform_billing_page.dart';
import '../../features/dashboard/presentation/pages/platform_clinics_page.dart';
import '../../features/departments/presentation/pages/platform_departments_page.dart';
import '../../features/reports/presentation/pages/platform_reports_page.dart';
import '../../features/revenue/presentation/pages/platform_revenue_page.dart';
import '../../features/tickets/presentation/pages/platform_support_tickets_page.dart';
import '../../features/users/presentation/pages/platform_users_page.dart';

class PlatformNavigationHelper {
  static void navigateTo(
    BuildContext context,
    int targetIndex,
    int currentIndex,
  ) {
    if (targetIndex == currentIndex) return;

    Widget page;
    switch (targetIndex) {
      case 0:
        page = const PlatformClinicsPage();
        break;
      case 1:
        page = const PlatformDepartmentsPage();
        break;
      case 2:
        page = const PlatformUsersPage();
        break;
      case 3:
        page = const PlatformBillingPage();
        break;
      case 4:
        page = const PlatformRevenuePage();
        break;
      case 5:
        page = const PlatformReportsPage();
        break;
      case 6:
        page = const PlatformSupportTicketsPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => page,
        transitionDuration: Duration.zero,
      ),
    );
  }
}
