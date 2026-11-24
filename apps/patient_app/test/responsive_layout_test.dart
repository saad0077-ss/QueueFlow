import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';
import 'package:patient_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:patient_app/features/home/presentation/bloc/home_event.dart';
import 'package:patient_app/features/home/presentation/bloc/home_state.dart';
import 'package:patient_app/features/home/presentation/widgets/laptop/patient_laptop_header.dart';
import 'package:patient_app/features/home/presentation/widgets/laptop/patient_laptop_sidebar.dart';
import 'package:patient_app/features/home/presentation/widgets/patient_bottom_nav_bar.dart';
import 'package:patient_app/features/home/presentation/widgets/patient_responsive_home_shell.dart';
import 'package:patient_app/features/home/presentation/widgets/tablet/patient_tablet_nav_rail.dart';
import 'package:patient_app/features/profile/domain/entities/patient_profile_entity.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class _FakeHomeBloc extends Bloc<HomeEvent, HomeState> implements HomeBloc {
  _FakeHomeBloc(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileBloc extends Bloc<ProfileEvent, ProfileState>
    implements ProfileBloc {
  _FakeProfileBloc(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const sampleClinic = ClinicEntity(
    id: 'sunrise-health',
    name: 'Sunrise Health Clinic',
    initials: 'SH',
    category: 'General & Family Clinic',
    rating: 4.9,
    reviewCount: 342,
    distance: '0.8 km',
    city: 'Kochi',
    address: 'Metro Health Plaza, Palarivattom',
    phone: '+91 98460 11111',
    consultationFee: '₹100',
    openingHours: '08:00 AM - 09:00 PM',
    currentToken: 'A-027',
    waitingCount: 2,
  );

  Widget createSubject({
    required Size screenSize,
    required HomeState homeState,
  }) {
    const profile = PatientProfileEntity(
      id: 'patient-123',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+91 98765 43210',
      initials: 'JD',
      healthId: 'QF-1234',
      dob: '01 Jan 1995',
      memberSince: 'Jan 2026',
      loyaltyCredits: 50,
      emergencyContactName: 'Jane Doe',
      emergencyContactRelation: 'Spouse',
      emergencyContactPhone: '+91 98765 00000',
      bp: '120/80',
      sugar: '95',
      weight: '70',
      height: '175',
      bmi: '22.8',
      allergies: [],
      insuranceProvider: 'Star Health',
      insurancePolicyNo: 'POL-123',
      insuranceValidTill: '2028',
      insuranceCoverage: '5L',
      visitsCount: 4,
    );

    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>.value(value: _FakeHomeBloc(homeState)),
            BlocProvider<ProfileBloc>.value(
              value: _FakeProfileBloc(const ProfileState(profile: profile)),
            ),
          ],
          child: PatientResponsiveHomeShell(
            state: homeState,
            bloc: _FakeHomeBloc(homeState),
            tabs: const [
              Text('Tab 0 Content'),
              Text('Tab 1 Content'),
              Text('Tab 2 Content'),
              Text('Tab 3 Content'),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('Laptop view (>= 1100px) displays permanent Sidebar & Laptop Header', (tester) async {
    const state = HomeState(
      currentTabIndex: 0,
      activeTicket: null,
      allClinics: [sampleClinic],
      userName: 'John Doe',
      userInitials: 'JD',
    );

    await tester.pumpWidget(createSubject(
      screenSize: const Size(1280, 800),
      homeState: state,
    ));
    await tester.pump();

    // Verify Laptop layout elements
    expect(find.byType(PatientLaptopSidebar), findsOneWidget);
    expect(find.byType(PatientLaptopHeader), findsOneWidget);
    expect(find.byType(PatientTabletNavRail), findsNothing);
    expect(find.byType(PatientBottomNavBar), findsNothing);
    expect(find.text('Tab 0 Content'), findsOneWidget);
  });

  testWidgets('Tablet view (680px - 1099px) displays Tablet Navigation Rail', (tester) async {
    const state = HomeState(
      currentTabIndex: 0,
      activeTicket: null,
      allClinics: [sampleClinic],
      userName: 'John Doe',
      userInitials: 'JD',
    );

    await tester.pumpWidget(createSubject(
      screenSize: const Size(820, 1024),
      homeState: state,
    ));
    await tester.pump();

    // Verify Tablet layout elements
    expect(find.byType(PatientTabletNavRail), findsOneWidget);
    expect(find.byType(PatientLaptopSidebar), findsNothing);
    expect(find.byType(PatientBottomNavBar), findsNothing);
    expect(find.text('Tab 0 Content'), findsOneWidget);
  });

  testWidgets('Mobile view (< 680px) displays standard Bottom Navigation Bar', (tester) async {
    const state = HomeState(
      currentTabIndex: 0,
      activeTicket: null,
      allClinics: [sampleClinic],
      userName: 'John Doe',
      userInitials: 'JD',
    );

    await tester.pumpWidget(createSubject(
      screenSize: const Size(390, 844),
      homeState: state,
    ));
    await tester.pump();

    // Verify Mobile layout elements
    expect(find.byType(PatientBottomNavBar), findsOneWidget);
    expect(find.byType(PatientLaptopSidebar), findsNothing);
    expect(find.byType(PatientTabletNavRail), findsNothing);
    expect(find.text('Tab 0 Content'), findsOneWidget);
  });
}
