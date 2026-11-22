import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:patient_app/features/profile/domain/entities/patient_payment_item_entity.dart';
import 'package:patient_app/features/profile/domain/entities/patient_queue_history_entity.dart';
import 'package:patient_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:patient_app/features/profile/presentation/pages/booking_history_screen.dart';
import 'package:patient_app/features/profile/presentation/pages/live_queue_history_screen.dart';
import 'package:patient_app/features/profile/presentation/widgets/payment_history/payment_history_sheet.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class _FakeProfileRepository implements ProfileRepository {
  final List<PatientQueueHistoryEntity> queueHistory;
  final List<PatientPaymentItemEntity> paymentHistory;

  _FakeProfileRepository({
    this.queueHistory = const [],
    this.paymentHistory = const [],
  });

  @override
  Future<List<PatientQueueHistoryEntity>> getQueueHistory() async => queueHistory;

  @override
  Stream<List<PatientQueueHistoryEntity>> watchQueueHistory() => Stream.value(queueHistory);

  @override
  Future<List<PatientPaymentItemEntity>> getPaymentHistory() async => paymentHistory;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBookingRepository implements BookingRepository {
  final List<AppointmentEntity> appointments;

  _FakeBookingRepository({this.appointments = const []});

  @override
  Future<List<AppointmentEntity>> getUserAppointments({String? customerId, String? customerEmail}) async => appointments;

  @override
  Stream<List<AppointmentEntity>> watchUserAppointments({String? customerId, String? customerEmail}) => Stream.value(appointments);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  final sampleQueueItems = [
    PatientQueueHistoryEntity(
      id: 'qh-active',
      token: 'A-024',
      clinicId: 'smile-dental',
      clinicName: 'Smile Dental Clinic',
      departmentName: 'Dental Department',
      serviceName: 'Teeth Cleaning',
      doctorName: 'Dr. Rahul Menon',
      joinedTime: '11:00 AM',
      date: 'Today',
      position: 3,
      estWaitMin: 15,
      status: 'waiting',
      isActive: true,
      joinedAt: DateTime.now(),
    ),
    const PatientQueueHistoryEntity(
      id: 'qh-101',
      token: 'B-005',
      clinicId: 'sunrise-health',
      clinicName: 'Sunrise Health Clinic',
      departmentName: 'General Medicine',
      serviceName: 'General Consultation',
      doctorName: 'Dr. Priya Sharma',
      joinedTime: '10:15 AM',
      date: 'Today',
      waitTime: '18 mins',
      status: 'completed',
      isActive: false,
    ),
  ];

  final sampleAppointments = [
    AppointmentEntity(
      id: 'apt-1',
      bookingRef: 'QF-89412',
      clinicId: 'c-1',
      clinicName: 'Sunrise Health Clinic',
      clinicAddress: '12 Marine Drive, Fort Kochi',
      customerId: 'u-1',
      customerName: 'Alex Morgan',
      customerPhone: '+91 98450 12345',
      customerEmail: 'alex@example.com',
      doctorId: 'd-1',
      doctorName: 'Dr. Sarah Jenkins',
      doctorSpecialty: 'General Physician',
      serviceId: 's-1',
      serviceName: 'General Consultation',
      serviceDuration: 20,
      servicePrice: 350.0,
      dateRaw: '2026-11-20',
      timeRaw: '10:30 AM',
      dateTime: 'Today, 10:30 AM',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    AppointmentEntity(
      id: 'apt-2',
      bookingRef: 'QF-72109',
      clinicId: 'c-2',
      clinicName: 'Metro Dental Care',
      clinicAddress: '45 MG Road, Bangalore',
      customerId: 'u-1',
      customerName: 'Alex Morgan',
      customerPhone: '+91 98450 12345',
      customerEmail: 'alex@example.com',
      doctorId: 'd-2',
      doctorName: 'Dr. Robert Chen',
      doctorSpecialty: 'Dental Surgeon',
      serviceId: 's-2',
      serviceName: 'Dental Checkup & Polish',
      serviceDuration: 30,
      servicePrice: 500.0,
      dateRaw: '2026-11-22',
      timeRaw: '02:00 PM',
      dateTime: 'Nov 22, 02:00 PM',
      status: 'upcoming',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final samplePayments = [
    const PatientPaymentItemEntity(
      id: 'pay-1',
      receiptNo: 'REC-2026-48210',
      bookingId: 'QF-48210',
      clinicId: 'sunrise-health',
      clinicName: 'Sunrise Health Clinic',
      department: 'General Medicine',
      service: 'General Consultation',
      doctor: 'Dr. Priya Sharma',
      amount: 500,
      status: 'paid',
      date: '12 Jun 2026, 10:42 AM',
      method: 'Razorpay UPI',
      transactionId: 'pay_RzpA101Qf48210',
    ),
  ];

  group('LiveQueueHistoryScreen tests', () {
    testWidgets('Renders empty state when user has no joined queues', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = _FakeProfileRepository(queueHistory: const []);
      await tester.pumpWidget(wrapWidget(LiveQueueHistoryScreen(repository: repo)));
      await tester.pumpAndSettle();

      expect(find.text('Live Queue History'), findsOneWidget);
      expect(find.text('No queue tokens'), findsOneWidget);
      expect(find.text('ACTIVE LIVE TOKEN'), findsNothing);
    });

    testWidgets('Renders spotlight card, tabs, and queue cards when populated', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = _FakeProfileRepository(queueHistory: sampleQueueItems);
      await tester.pumpWidget(wrapWidget(LiveQueueHistoryScreen(repository: repo)));
      await tester.pumpAndSettle();

      // Check spotlight active ticket
      expect(find.text('ACTIVE LIVE TOKEN'), findsOneWidget);
      expect(find.text('A-024'), findsWidgets);
      expect(find.text('Track Live Queue in Tracker'), findsOneWidget);

      // Check stats
      expect(find.text('JOINED'), findsOneWidget);
      expect(find.text('SERVED'), findsOneWidget);
      expect(find.text('AVG WAIT'), findsOneWidget);

      // Check filter tabs
      expect(find.textContaining('All Queues (2)'), findsOneWidget);
      expect(find.text('Active (1)'), findsOneWidget);
      expect(find.textContaining('Completed (1)'), findsOneWidget);

      // Check queue cards
      expect(find.text('B-005'), findsOneWidget);
      expect(find.textContaining('General Consultation'), findsOneWidget);
    });
  });

  group('BookingHistoryScreen tests', () {
    testWidgets('Renders empty state when user has no appointments', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = _FakeBookingRepository(appointments: const []);
      await tester.pumpWidget(wrapWidget(BookingHistoryScreen(repository: repo)));
      await tester.pumpAndSettle();

      expect(find.text('Booking History'), findsOneWidget);
      expect(find.text('No appointments found'), findsOneWidget);
    });

    testWidgets('Renders stats bar, search bar, and appointment cards when populated', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = _FakeBookingRepository(appointments: sampleAppointments);
      await tester.pumpWidget(wrapWidget(BookingHistoryScreen(repository: repo)));
      await tester.pumpAndSettle();

      // Header & Stats
      expect(find.text('Booking History'), findsOneWidget);
      expect(find.text('TOTAL VISITS'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('UPCOMING'), findsWidgets);

      // Search bar
      expect(find.byType(TextField), findsOneWidget);

      // Filter tabs
      expect(find.textContaining('All (2)'), findsOneWidget);

      // Appointment items
      expect(find.text('Sunrise Health Clinic'), findsWidgets);
      expect(find.text('Metro Dental Care'), findsWidgets);
    });
  });

  group('PaymentHistorySheet tests', () {
    testWidgets('Renders empty state when no payments exist', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = _FakeProfileRepository(paymentHistory: const []);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => PaymentHistorySheet.show(ctx, repository: repo),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Payment History'), findsOneWidget);
      expect(find.text('No payment records found'), findsOneWidget);
    });

    testWidgets('Renders payment items when populated', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = _FakeProfileRepository(paymentHistory: samplePayments);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => PaymentHistorySheet.show(ctx, repository: repo),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Payment History'), findsOneWidget);
      expect(find.text('TOTAL SPENT'), findsOneWidget);
      expect(find.text('1 Paid'), findsOneWidget);
      expect(find.text('✓ Verified'), findsOneWidget);
      expect(find.text('Sunrise Health Clinic'), findsOneWidget);
    });
  });
}
