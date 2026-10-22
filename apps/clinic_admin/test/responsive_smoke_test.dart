import 'package:clinic_admin/features/dashboard/presentation/widgets/clinic_sidebar.dart';
import 'package:clinic_admin/features/dashboard/presentation/widgets/dashboard_main_columns.dart';
import 'package:clinic_admin/features/dashboard/presentation/widgets/dashboard_stats_row.dart';
import 'package:clinic_admin/features/services/domain/entities/clinic_doctor_entity.dart';
import 'package:clinic_admin/features/services/domain/entities/service_department_entity.dart';
import 'package:clinic_admin/features/services/domain/entities/clinic_service_entity.dart';
import 'package:clinic_admin/features/services/presentation/widgets/service_capacity_quota_card.dart';
import 'package:clinic_admin/features/services/presentation/widgets/service_edit_dialog.dart';
import 'package:clinic_admin/features/services/presentation/widgets/services_cards_grid.dart';
import 'package:clinic_admin/features/services/presentation/widgets/services_catalog_section_header.dart';
import 'package:clinic_admin/features/services/presentation/widgets/services_view_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

const _pending = ClinicServiceEntity(
  id: 'p1',
  name: 'Invisalign Clear Aligners & 3D Scan With A Long Name',
  description:
      'A long description that goes on and on to fill two lines of text in the card.',
  status: 'pending_approval',
  departmentId: 'dept-dent',
  departmentName: 'Dental & Oral Surgery',
  assignedStaff: ['Dr. Priya', 'Dr. Rahul Menon'],
);
const _active = ClinicServiceEntity(id: 'a1', name: 'General Consultation');

const _departments = [
  ServiceDepartmentEntity(
    id: 'dept-dent',
    code: 'DENT',
    name: 'Dental & Oral Surgery',
    icon: '🦷',
    standardServices: [
      StandardServiceTemplate(
        name: 'Teeth Cleaning & Scaling',
        duration: 30,
        suggestedPrice: 800,
      ),
    ],
  ),
  ServiceDepartmentEntity(
    id: 'dept-derm',
    code: 'DERM',
    name: 'Dermatology & Cosmetology',
    icon: '✨',
    standardServices: [
      StandardServiceTemplate(
        name: 'Acne & Skin Consultation',
        duration: 20,
        suggestedPrice: 600,
      ),
    ],
  ),
];

const _doctors = [ClinicDoctorEntity(name: 'Dr. Priya')];

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  ),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final width in [360.0, 768.0, 1440.0]) {
    testWidgets('services + dashboard render without overflow at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              ServicesViewHeader(
                planPill: 'SOLO DOCTOR PRACTICE',
                planName: 'Solo Doctor Plan',
              ),
              ServiceCapacityQuotaCard(
                currentCount: 2,
                limit: 1,
                isUnlimited: false,
                planName: 'Solo Doctor Plan',
                onUpgrade: () {},
              ),
              const ServicesCatalogSectionHeader(count: 2),
              ServicesCardsGrid(
                services: const [_pending, _active],
                isLimitReached: true,
                availableSlots: 0,
                planName: 'Solo Doctor Plan',
                isUnlimited: false,
                onEdit: (_) {},
                onToggle: (_) {},
                onDelete: (_) {},
                onAdd: () {},
                onUpgrade: () {},
              ),
              const DashboardStatsRow(waitingCount: 4),
              DashboardMainColumns(
                currentToken: 'A-030',
                waitingCount: 4,
                onCallNext: () {},
                onViewQueue: () {},
                onAddWalkIn: () {},
                onCreateAppointment: () {},
                onTogglePauseQueue: () {},
                isQueuePaused: false,
              ),
              const SizedBox(
                height: 700,
                child: Row(
                  children: [ClinicSidebar(compact: true), ClinicSidebar()],
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('edit dialog opens for pending service at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ServiceEditDialog.show(
                context,
                service: _pending,
                departments: _departments,
                doctors: _doctors,
                onSave: (_) {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Edit Treatment Service'), findsOneWidget);

      // Switching department must not trip the dropdown value assertion.
      await tester.tap(find.text('🦷 Dental & Oral Surgery (DENT)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('✨ Dermatology & Cosmetology (DERM)').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Acne & Skin Consultation'), findsWidgets);
    });

    testWidgets('dialog explains when no departments are assigned at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ServiceEditDialog.show(
                context,
                departments: const [],
                doctors: _doctors,
                onSave: (_) {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('No departments are assigned'),
        findsOneWidget,
      );
    });
  }
}
