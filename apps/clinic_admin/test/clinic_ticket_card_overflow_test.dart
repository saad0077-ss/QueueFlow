import 'package:clinic_admin/features/tickets/domain/entities/clinic_support_ticket_entity.dart';
import 'package:clinic_admin/features/tickets/presentation/widgets/clinic_tickets_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

ClinicSupportTicketEntity _sampleTicket({
  required String id,
  required String ticketNumber,
  String? linkedTokenNumber,
  String? assignedTo,
}) {
  return ClinicSupportTicketEntity(
    id: id,
    ticketNumber: ticketNumber,
    patientName: 'Muhammed Saad VeryLongPatientName',
    patientPhone: '8921873547',
    clinicId: 'clinic-gh',
    clinicName: 'Green Heaven Clinic',
    linkedTokenNumber: linkedTokenNumber,
    category: 'queue',
    subject: 'Waiting room delay exceeding 20 minutes',
    description:
        'Token GH-OJ-004 at Green Heaven Clinic - waiting past estimated time.',
    status: 'open',
    priority: 'urgent',
    slaMinutes: 15,
    assignedTo: assignedTo,
    createdAt: '3 hours ago',
    createdAtDate: DateTime.now().subtract(const Duration(hours: 3, minutes: 40)),
    messages: const [],
  );
}

Future<void> _pumpGridAtSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: ClinicTicketsGrid(
          selectedTicketId: null,
          onSelectTicket: (_) {},
          tickets: [
            _sampleTicket(
              id: 't1',
              ticketNumber: 'TK-8547',
              linkedTokenNumber: 'GH-OJ-004',
              assignedTo: 'Clinic Admin Coordinator',
            ),
            _sampleTicket(
              id: 't2',
              ticketNumber: 'TK-1758',
              linkedTokenNumber: 'GH-CON-01234',
              assignedTo: null,
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('ClinicTicketsGrid renders without overflow in 2-col layout', (
    tester,
  ) async {
    await _pumpGridAtSize(tester, const Size(680, 800));
    expect(tester.takeException(), isNull);
    expect(find.text('TK-8547'), findsOneWidget);
    expect(find.text('Token #GH-OJ-004'), findsOneWidget);
  });

  testWidgets('ClinicTicketsGrid renders without overflow on narrow mobile', (
    tester,
  ) async {
    await _pumpGridAtSize(tester, const Size(360, 800));
    expect(tester.takeException(), isNull);
    expect(find.text('TK-8547'), findsOneWidget);
    expect(find.text('Green Heaven Clinic'), findsWidgets);
  });
}
