import 'package:clinic_admin/features/notifications/domain/entities/clinic_notification_item.dart';
import 'package:clinic_admin/features/notifications/presentation/widgets/clinic_notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

void main() {
  group('Clinic Notifications Tests', () {
    final sampleItem = ClinicNotificationItem(
      id: 'test_1',
      title: 'Token #A-024 (waiting)',
      body: 'John Doe joined General Consultation',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: ClinicNotificationType.queue,
      routeNav: 'Live Queue',
      isRead: false,
    );

    test('ClinicNotificationItem copyWith works', () {
      final read = sampleItem.copyWith(isRead: true);
      expect(read.isRead, isTrue);
      expect(read.title, sampleItem.title);
      expect(read.id, sampleItem.id);
    });

    testWidgets('ClinicNotificationTile renders and handles tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ClinicNotificationTile(
              item: sampleItem,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Token #A-024 (waiting)'), findsOneWidget);
      expect(find.text('John Doe joined General Consultation'), findsOneWidget);
      expect(find.text('5m ago'), findsOneWidget);

      await tester.tap(find.byType(ClinicNotificationTile));
      expect(tapped, isTrue);
    });
  });
}
