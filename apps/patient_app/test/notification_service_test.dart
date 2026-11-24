import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/services/notification_navigator.dart';

void main() {
  group('NotificationNavigator Route Parsing Tests', () {
    test('parses live queue route to tab 1', () {
      expect(NotificationNavigator.parseTargetTab('/live_queue'), 1);
      expect(
        NotificationNavigator.parseTargetTab('/live_queue?ticketId=123'),
        1,
      );
    });

    test('parses my bookings route to tab 2', () {
      expect(NotificationNavigator.parseTargetTab('/my_bookings'), 2);
      expect(
        NotificationNavigator.parseTargetTab('/my_bookings?appointmentId=456'),
        2,
      );
    });

    test('parses home route to tab 0', () {
      expect(NotificationNavigator.parseTargetTab('/home'), 0);
    });

    test('returns null for unknown routes', () {
      expect(NotificationNavigator.parseTargetTab('/unknown_path'), isNull);
      expect(NotificationNavigator.parseTargetTab(null), isNull);
    });

    test('parses support chat ticket ID accurately', () {
      expect(
        NotificationNavigator.parseSupportTicketId(
          '/support_chat?ticketId=ticket_9988',
        ),
        'ticket_9988',
      );
      expect(NotificationNavigator.parseSupportTicketId('/live_queue'), isNull);
      expect(NotificationNavigator.parseSupportTicketId(null), isNull);
    });
  });
}
