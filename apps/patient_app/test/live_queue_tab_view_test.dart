import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/home/domain/entities/active_ticket_entity.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';
import 'package:patient_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:patient_app/features/home/presentation/bloc/home_event.dart';
import 'package:patient_app/features/home/presentation/bloc/home_state.dart';
import 'package:patient_app/features/home/presentation/widgets/live_queue_tab_view.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class _FakeHomeBloc extends Bloc<HomeEvent, HomeState> implements HomeBloc {
  _FakeHomeBloc(super.initialState);

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
    schedule: {
      'monday': {'isOpen': true, 'openTime': '00:00', 'closeTime': '23:59'},
      'tuesday': {'isOpen': true, 'openTime': '00:00', 'closeTime': '23:59'},
      'wednesday': {'isOpen': true, 'openTime': '00:00', 'closeTime': '23:59'},
      'thursday': {'isOpen': true, 'openTime': '00:00', 'closeTime': '23:59'},
      'friday': {'isOpen': true, 'openTime': '00:00', 'closeTime': '23:59'},
      'saturday': {'isOpen': true, 'openTime': '00:00', 'closeTime': '23:59'},
      'sunday': {'isOpen': true, 'openTime': '00:00', 'closeTime': '23:59'},
    },
  );

  Widget createSubject(HomeState state) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: BlocProvider<HomeBloc>.value(
          value: _FakeHomeBloc(state),
          child: const LiveQueueTabView(),
        ),
      ),
    );
  }

  testWidgets('Renders Queue Radar View when there is no active ticket', (tester) async {
    const state = HomeState(
      activeTicket: null,
      allClinics: [sampleClinic],
    );

    await tester.pumpWidget(createSubject(state));
    await tester.pump();

    // Verify radar headers & cards
    expect(find.text('Live Queue'), findsOneWidget);
    expect(find.text('FASTEST QUEUE AVAILABLE'), findsNothing);
    expect(find.text('Quick Join Fastest Queue'), findsNothing);
    expect(find.text('Live Clinic Wait Times'), findsOneWidget);
    expect(find.text('Join Digital Queue'), findsOneWidget);
  });

  testWidgets('Renders Active Ticket View when user has active ticket', (tester) async {
    const state = HomeState(
      activeTicket: ActiveTicketEntity(
        id: 'q-024',
        token: 'A-024',
        clinicId: 'smile-dental',
        clinicName: 'Smile Dental Clinic',
        position: 3,
        estWaitMin: 15,
        nowServing: 'A-021',
        status: 'waiting',
      ),
      allClinics: [sampleClinic],
    );

    await tester.pumpWidget(createSubject(state));
    await tester.pump();

    // Verify active ticket view elements
    expect(find.text('Live Queue'), findsOneWidget);
    expect(find.text('Smile Dental Clinic'), findsOneWidget);
    expect(find.text('A-024'), findsOneWidget);
    expect(find.text('Ahead of you'), findsOneWidget);
    expect(find.text('Est. wait'), findsOneWidget);
    expect(find.text('Queue status'), findsOneWidget);
    expect(find.text('Get Directions'), findsOneWidget);
    expect(find.text('Leave / Cancel Spot'), findsOneWidget);
  });
}
