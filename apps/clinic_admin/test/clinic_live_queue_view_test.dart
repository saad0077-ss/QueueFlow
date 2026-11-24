import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'package:clinic_admin/features/services/domain/entities/clinic_service_entity.dart';
import 'package:clinic_admin/features/services/domain/entities/service_department_entity.dart';
import 'package:clinic_admin/features/queue/domain/entities/clinic_queue_item_entity.dart';
import 'package:clinic_admin/features/queue/domain/entities/clinic_queue_summary_entity.dart';
import 'package:clinic_admin/features/queue/domain/repositories/clinic_queue_repository.dart';
import 'package:clinic_admin/features/queue/presentation/pages/clinic_live_queue_view.dart';

class _FakeClinicQueueRepository implements ClinicQueueRepository {
  final _summaryController =
      StreamController<ClinicQueueSummaryEntity>.broadcast();
  final _itemsController =
      StreamController<List<ClinicQueueItemEntity>>.broadcast();
  final _servicesController =
      StreamController<List<ClinicServiceEntity>>.broadcast();

  ClinicQueueSummaryEntity summary = const ClinicQueueSummaryEntity(
    currentToken: 'SH-GC-001',
    waitingCount: 3,
    avgWaitTime: '15 min',
    isPaused: false,
    status: 'open',
    clinicName: 'Sunrise Health Clinic',
  );

  List<ServiceDepartmentEntity> departments = [
    const ServiceDepartmentEntity(
      id: 'dept-gen',
      code: 'GM',
      name: 'General Medicine',
      icon: '🩺',
    ),
  ];

  final List<ClinicServiceEntity> services = const [
    ClinicServiceEntity(
      id: 'svc-1',
      name: 'General Consultation',
      description: 'Comprehensive medical examination and triage.',
      duration: 20,
      price: 500,
      departmentId: 'dept-gen',
      departmentName: 'General Medicine',
      status: 'active',
    ),
  ];

  List<ClinicQueueItemEntity> items = [
    ClinicQueueItemEntity(
      id: 'item-1',
      token: 'SH-GC-001',
      clinicId: 'sunrise-health',
      patientName: 'Vivek Nair',
      serviceName: 'General Consultation',
      doctorName: 'Dr. Priya',
      phone: '+91 98450 11234',
      email: 'vivek.nair@email.com',
      joinedTime: '10:40 AM',
      joinedAt: DateTime(2026, 6, 30, 10, 40),
      estDuration: '20 min',
      status: 'called',
      note: 'Prefers morning slots.',
    ),
    ClinicQueueItemEntity(
      id: 'item-2',
      token: 'SH-GC-002',
      clinicId: 'sunrise-health',
      patientName: 'Meera Pillai',
      serviceName: 'General Consultation',
      doctorName: 'Dr. Priya',
      phone: '+91 98450 22345',
      email: 'meera.p@email.com',
      joinedTime: '10:45 AM',
      joinedAt: DateTime(2026, 6, 30, 10, 45),
      estDuration: '15 min',
      status: 'waiting',
      note: 'First visit.',
    ),
  ];

  @override
  Stream<ClinicQueueSummaryEntity> watchQueueSummary() {
    scheduleMicrotask(() => _summaryController.add(summary));
    return _summaryController.stream;
  }

  @override
  Stream<List<ClinicQueueItemEntity>> watchQueueItems() {
    scheduleMicrotask(() => _itemsController.add(items));
    return _itemsController.stream;
  }

  @override
  Future<List<ServiceDepartmentEntity>> getDepartments() async => departments;

  @override
  Stream<List<ClinicServiceEntity>> watchServices() {
    scheduleMicrotask(() => _servicesController.add(services));
    return _servicesController.stream;
  }

  @override
  Future<void> callNextToken([String? serviceName]) async {}

  @override
  Future<void> callSpecificToken(String token) async {}

  @override
  Future<void> completeToken(String token) async {}

  @override
  Future<void> skipToken(String token) async {}

  @override
  Future<void> removeToken(String token) async {}

  @override
  Future<void> togglePauseQueue(bool isPaused) async {}

  @override
  Future<void> setServiceClosedToday(String service, bool closed) async {}

  @override
  Future<ClinicQueueItemEntity> addWalkInPatient({
    required String name,
    required String phone,
    required String service,
    String? doctor,
    String? note,
    String? email,
    String? department,
  }) async {
    return items.first;
  }

  @override
  Future<List<String>> getAvailableServices() async => ['General Consultation'];

  @override
  Future<List<String>> getAvailableDoctors() async => ['Dr. Priya'];
}

void main() {
  testWidgets(
    'ClinicLiveQueueView renders department overview and drills down to service queue',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeRepo = _FakeClinicQueueRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: ClinicLiveQueueView(repository: fakeRepo)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Sub-View 1: Department Overview Header & Metrics
      expect(find.text('LIVE QUEUE CONSOLE'), findsOneWidget);
      expect(find.text('Live Queue Management'), findsOneWidget);
      expect(find.text('Add Walk-In Patient'), findsOneWidget);
      expect(find.text('Queue Open'), findsOneWidget);

      // Verify Summary Cards
      expect(find.text('Departments Active'), findsOneWidget);
      expect(find.text('Services Configured'), findsOneWidget);
      expect(find.text('Patients Waiting'), findsOneWidget);
      expect(find.text('Average Wait Time'), findsOneWidget);

      // Verify Department Card & Service Card
      expect(find.text('General Medicine'), findsOneWidget);
      expect(find.text('General Consultation'), findsOneWidget);
      expect(find.text('View Queue →'), findsOneWidget);

      // Tap "View Queue →" to drill down into Sub-View 2: Service Live Queue View
      await tester.ensureVisible(find.text('View Queue →'));
      await tester.tap(find.text('View Queue →'));
      await tester.pumpAndSettle();

      // Verify Sub-View 2 (Breadcrumbs, Service Header & Table)
      expect(find.text('Back to All Departments'), findsOneWidget);
      expect(find.text('Call Next In Line'), findsOneWidget);
      expect(find.text('Vivek Nair'), findsWidgets);
      expect(find.text('Meera Pillai'), findsOneWidget);
      expect(find.text('SERVING NOW'), findsOneWidget);

      // Tap on Vivek Nair row to open Patient Queue Details drawer
      await tester.tap(find.text('Vivek Nair').last);
      await tester.pumpAndSettle();

      expect(find.text('Patient Queue Details'), findsOneWidget);
      expect(find.text('Contact Phone'), findsOneWidget);
      expect(find.text('+91 98450 11234'), findsOneWidget);
      expect(find.text('Mark Consultation Complete'), findsOneWidget);
      expect(find.text('Skip to Back of Line'), findsOneWidget);
      expect(find.text('Remove from Queue'), findsOneWidget);
    },
  );

  testWidgets(
    'ClinicLiveQueueView deduplicates department cards when duplicates exist in repository',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeRepo = _FakeClinicQueueRepository();
      // Simulate duplicate departments from Firestore
      fakeRepo.departments.clear();
      fakeRepo.departments.addAll(const [
        ServiceDepartmentEntity(
          id: 'dept-1',
          code: 'GEN',
          name: 'General Medicine',
          icon: '🩺',
        ),
        ServiceDepartmentEntity(
          id: 'dept-2',
          code: 'GEN',
          name: 'General Medicine',
          icon: '🩺',
        ),
        ServiceDepartmentEntity(
          id: 'dept-3',
          code: 'ORTHO',
          name: 'Orthopedics & Sports Rehab',
          icon: '🦴',
        ),
        ServiceDepartmentEntity(
          id: 'dept-4',
          code: 'PEDI',
          name: 'Pediatrics & Child Care',
          icon: '👶',
        ),
        ServiceDepartmentEntity(
          id: 'dept-5',
          code: 'PEDI',
          name: 'Pediatrics & Child Care',
          icon: '👶',
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: ClinicLiveQueueView(repository: fakeRepo)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Must be exactly one of each department, not duplicated
      expect(find.text('General Medicine'), findsOneWidget);
      expect(find.text('Orthopedics & Sports Rehab'), findsOneWidget);
      expect(find.text('Pediatrics & Child Care'), findsOneWidget);
    },
  );
}
