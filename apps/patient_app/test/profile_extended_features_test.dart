import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/domain/entities/favorite_clinic_entity.dart';
import 'package:patient_app/features/profile/domain/entities/patient_payment_item_entity.dart';
import 'package:patient_app/features/profile/domain/entities/patient_review_entity.dart';
import 'package:patient_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:patient_app/features/profile/presentation/pages/favorite_clinics_screen.dart';
import 'package:patient_app/features/profile/presentation/pages/my_reviews_screen.dart';
import 'package:patient_app/features/profile/presentation/pages/payment_history_screen.dart';
import 'package:patient_app/features/profile/presentation/widgets/reviews/my_reviews_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class _FakeExtendedProfileRepository implements ProfileRepository {
  final List<PatientPaymentItemEntity> payments;
  final List<FavoriteClinicEntity> favorites;
  final List<PatientReviewEntity> reviews;

  _FakeExtendedProfileRepository({
    this.payments = const [],
    this.favorites = const [],
    this.reviews = const [],
  });

  @override
  Future<List<PatientPaymentItemEntity>> getPaymentHistory() async => payments;

  @override
  Future<List<FavoriteClinicEntity>> getFavoriteClinics() async => favorites;

  @override
  Future<List<PatientReviewEntity>> getUserReviews() async => reviews;

  @override
  Future<void> toggleFavorite(String clinicId, {required bool isFavorite}) async {}

  @override
  Future<void> deleteReview(String id) async {}

  @override
  Future<PatientReviewEntity> addReview({
    required String clinicId,
    required String clinicName,
    required String doctorName,
    required int rating,
    required List<String> tags,
    required String comment,
    required bool isAnonymous,
  }) async {
    return PatientReviewEntity(
      id: 'rev-new',
      clinicId: clinicId,
      clinicName: clinicName,
      doctorName: doctorName,
      doctorSpecialty: 'General Consultant',
      service: 'General Checkup',
      rating: rating,
      doctorRating: rating,
      clinicRating: rating,
      comment: comment,
      date: 'Today',
      tags: tags,
      doctorTags: ['Helpful'],
      isAnonymous: isAnonymous,
      helpfulCount: 0,
    );
  }

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

  final samplePayments = [
    const PatientPaymentItemEntity(
      id: 'pay-001',
      clinicId: 'c-1',
      clinicName: 'Smile Dental Clinic',
      service: 'Dental Cleaning',
      doctor: 'Dr. Rahul Sharma',
      amount: 150.0,
      status: 'paid',
      date: '18 Nov 2026',
      type: 'queue',
      method: 'UPI (GPay)',
      receiptNo: 'REC-2026-089',
      token: 'A-024',
      bookingId: 'APT-5501',
    ),
    const PatientPaymentItemEntity(
      id: 'pay-002',
      clinicId: 'c-2',
      clinicName: 'Sunrise Health Clinic',
      service: 'General Consultation',
      doctor: 'Dr. Priya Menon',
      amount: 250.0,
      status: 'refunded',
      date: '10 Nov 2026',
      type: 'appointment',
      method: 'Razorpay UPI',
      receiptNo: 'REC-2026-042',
      bookingId: 'APT-5201',
      refundId: 'RFND-9921',
      refundReason: 'Slot rescheduled by clinic',
      refundToAccount: 'HDFC Bank ••4821',
      refundedAt: '10 Nov 2026, 04:30 PM',
    ),
  ];

  final sampleFavorites = [
    const FavoriteClinicEntity(
      id: 'c-1',
      name: 'Smile Dental Clinic',
      department: 'Dental Care & Orthodontics',
      rating: 4.9,
      reviewsCount: 312,
      distance: '1.2 km',
      waitingCount: 3,
      estWaitTime: '15 min',
      address: '2nd Floor, MG Road, Kochi',
      initials: 'SD',
      openHours: '9:00 AM - 8:00 PM',
      topDoctor: 'Dr. Rahul Sharma (Chief Orthodontist)',
      phone: '+91 98470 12345',
      iconEmoji: '🦷',
    ),
  ];

  final sampleReviews = [
    const PatientReviewEntity(
      id: 'rev-1',
      clinicId: 'c-1',
      clinicName: 'Smile Dental Clinic',
      doctorName: 'Dr. Rahul Sharma',
      doctorSpecialty: 'Senior Dental Surgeon',
      service: 'Root Canal Treatment',
      rating: 5,
      doctorRating: 5,
      clinicRating: 5,
      comment: 'Super polite doctor. Zero pain during root canal.',
      date: '12 Nov 2026',
      tags: ['Zero Pain', 'Clear Explanation'],
      doctorTags: ['Gentle Hand', 'Painless Treatment'],
      isAnonymous: false,
      helpfulCount: 4,
    ),
  ];

  group('PaymentHistoryScreen Widget Tests', () {
    testWidgets('renders header, hero KPI banner, tabs, and payment cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakeExtendedProfileRepository(payments: samplePayments);

      await tester.pumpWidget(
        wrapWidget(
          PaymentHistoryScreen(
            repository: fakeRepo,
            initialPayments: samplePayments,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Payment History'), findsOneWidget);
      expect(find.text('Invoices, queue tokens & refunds'), findsOneWidget);

      // Verify Hero Banner
      expect(find.text('100% Verified Invoices & Instant Refunds'), findsOneWidget);
      expect(find.text('GST Compliant'), findsOneWidget);
      expect(find.text('TOTAL PAID'), findsOneWidget);
      expect(find.text('REFUNDED'), findsOneWidget);

      // Verify Filter Tabs
      expect(find.text('All (2)'), findsOneWidget);
      expect(find.text('🎟️ Queue Tokens (1)'), findsOneWidget);
      expect(find.text('📅 Bookings (1)'), findsOneWidget);
      expect(find.text('↺ Refunded (1)'), findsOneWidget);

      // Verify Payment Cards
      expect(find.text('Smile Dental Clinic'), findsOneWidget);
      expect(find.text('Sunrise Health Clinic'), findsOneWidget);
      expect(find.text('₹150'), findsNWidgets(2)); // KPI Banner + Card
      expect(find.text('₹250'), findsNWidgets(2)); // KPI Banner + Card
      expect(find.text('✓ Paid'), findsOneWidget);
      expect(find.text('↺ Refunded'), findsOneWidget);
      expect(find.textContaining('Slot rescheduled by clinic'), findsOneWidget);
    });

    testWidgets('filter tabs filter payments accurately', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakeExtendedProfileRepository(payments: samplePayments);

      await tester.pumpWidget(
        wrapWidget(
          PaymentHistoryScreen(
            repository: fakeRepo,
            initialPayments: samplePayments,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure visible and tap Refunded filter tab
      final refundedTab = find.text('↺ Refunded (1)');
      await tester.ensureVisible(refundedTab);
      await tester.pumpAndSettle();
      await tester.tap(refundedTab);
      await tester.pumpAndSettle();

      expect(find.text('Sunrise Health Clinic'), findsOneWidget);
      expect(find.text('Smile Dental Clinic'), findsNothing);
    });
  });

  group('FavoriteClinicsScreen Widget Tests', () {
    testWidgets('renders hero banner, search bar, and favorite clinic card', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakeExtendedProfileRepository(favorites: sampleFavorites);

      await tester.pumpWidget(
        wrapWidget(
          FavoriteClinicsScreen(
            repository: fakeRepo,
            initialClinics: sampleFavorites,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Favorite Clinics'), findsOneWidget);
      expect(find.text('Saved doctors & preferred clinics'), findsOneWidget);

      // Verify Hero Banner
      expect(find.text('Personal Care Network'), findsOneWidget);
      expect(find.text('FAVORITES'), findsOneWidget);
      expect(find.text('LIVE QUEUE'), findsOneWidget);

      // Verify Favorite Card
      expect(find.text('Smile Dental Clinic'), findsOneWidget);
      expect(find.text('3 in queue (~15 min)'), findsOneWidget);
      expect(find.text('Book'), findsOneWidget);
      expect(find.text('Live Queue'), findsOneWidget);
      expect(find.text('📞'), findsOneWidget);
    });
  });

  group('MyReviewsScreen Widget Tests', () {
    testWidgets('renders hero banner, doctor rating box, dual score, and quote box', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakeExtendedProfileRepository(reviews: sampleReviews);

      await tester.pumpWidget(
        wrapWidget(
          BlocProvider(
            create: (_) => MyReviewsBloc(
              repository: fakeRepo,
              initialReviews: sampleReviews,
            ),
            child: const MyReviewsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('My Ratings & Reviews'), findsOneWidget);
      expect(find.text('Feedback shared across clinic visits'), findsOneWidget);
      expect(find.text('+ Review'), findsOneWidget);

      // Verify Hero Banner
      expect(find.text('Patient Experience Contribution'), findsOneWidget);
      expect(find.text('DOCTORS RATED'), findsOneWidget);
      expect(find.text('CLINICS RATED'), findsOneWidget);

      // Verify Review Card
      expect(find.text('Smile Dental Clinic'), findsOneWidget);
      expect(find.text('Dr. Rahul Sharma'), findsOneWidget);
      expect(find.text('Doctor Rating'), findsOneWidget);
      expect(find.text('👨‍⚕️ Doctor Care'), findsOneWidget);
      expect(find.text('🏥 Clinic Facility'), findsOneWidget);
      expect(find.text('"Super polite doctor. Zero pain during root canal."'), findsOneWidget);
      expect(find.text('4 patients found this helpful'), findsOneWidget);
      expect(find.text('✏️ Edit'), findsOneWidget);
      expect(find.text('🗑️ Delete'), findsOneWidget);
      expect(find.text('Write a New Clinic Review'), findsOneWidget);
    });

    testWidgets('renders empty state when user has no reviews (no mock data)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakeExtendedProfileRepository(reviews: const []);

      await tester.pumpWidget(
        wrapWidget(
          BlocProvider(
            create: (_) => MyReviewsBloc(
              repository: fakeRepo,
              initialReviews: const [],
            ),
            child: const MyReviewsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Reviews Yet'), findsOneWidget);
      expect(find.text('Rate Doctor & Clinic'), findsOneWidget);
    });
  });

  group('Empty States Without Mock Data Tests', () {
    testWidgets('PaymentHistoryScreen renders empty state when no transactions exist', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakeExtendedProfileRepository(payments: const []);

      await tester.pumpWidget(
        wrapWidget(
          PaymentHistoryScreen(
            repository: fakeRepo,
            initialPayments: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No transactions found'), findsOneWidget);
      expect(find.text('You have not made any consultations or queue payments yet.'), findsOneWidget);
    });

    testWidgets('FavoriteClinicsScreen renders empty state when no favorites exist', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakeExtendedProfileRepository(favorites: const []);

      await tester.pumpWidget(
        wrapWidget(
          FavoriteClinicsScreen(
            repository: fakeRepo,
            initialClinics: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Favorite Clinics Yet'), findsOneWidget);
      expect(find.text('🔍 Explore Clinics'), findsOneWidget);
    });
  });
}
