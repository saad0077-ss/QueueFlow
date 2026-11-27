import 'package:flutter/material.dart';

import '../../features/home/presentation/pages/patient_home_screen.dart';
import '../../features/profile/presentation/pages/help_support/concern_detail_chat_screen.dart';

class NotificationNavigator {
  const NotificationNavigator._();

  static String? _pendingRoute;

  static void setPendingRoute(String? route) {
    if (route != null && route.trim().isNotEmpty) {
      _pendingRoute = route.trim();
    }
  }

  static String? consumePendingRoute() {
    final r = _pendingRoute;
    _pendingRoute = null;
    return r;
  }

  static int? parseTargetTab(String? route) {
    if (route == null) return null;
    if (route.startsWith('/live_queue')) return 1;
    if (route.startsWith('/my_bookings')) return 2;
    if (route == '/home') return 0;
    return null;
  }

  static String? parseSupportTicketId(String? route) {
    if (route == null || !route.startsWith('/support_chat')) return null;
    final uri = Uri.tryParse(route);
    return uri?.queryParameters['ticketId'];
  }

  static void navigate(GlobalKey<NavigatorState> navKey, String? route) {
    if (route == null || route.isEmpty) return;
    final nav = navKey.currentState;
    if (nav == null) {
      setPendingRoute(route);
      return;
    }

    final ticketId = parseSupportTicketId(route);
    if (ticketId != null && ticketId.isNotEmpty) {
      nav.push(
        MaterialPageRoute(
          builder: (_) => ConcernDetailChatScreen(ticketId: ticketId),
        ),
      );
      return;
    }

    final tab = parseTargetTab(route);
    if (tab != null) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => PatientHomeScreen(initialTab: tab)),
        (r) => false,
      );
    }
  }
}
