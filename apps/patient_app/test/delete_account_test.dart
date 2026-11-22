import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/domain/entities/patient_profile_entity.dart';
import 'package:patient_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:patient_app/features/profile/domain/usecases/profile_usecases.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_state.dart';

class _FakeProfileRepository implements ProfileRepository {
  bool deleteAccountCalled = false;
  bool throwOnDelete = false;

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalled = true;
    if (throwOnDelete) {
      throw Exception('requires-recent-login');
    }
  }

  @override
  Future<PatientProfileEntity> getProfile() async {
    return const PatientProfileEntity(
      id: 'test-user',
      name: 'John Doe',
      initials: 'JD',
      email: 'john@example.com',
      phone: '+91 9999999999',
      healthId: 'QF-TEST-001',
      dob: '01 Jan 1990',
      memberSince: 'Jan 2026',
      loyaltyCredits: 100,
      emergencyContactName: 'Jane',
      emergencyContactRelation: 'Spouse',
      emergencyContactPhone: '+91 8888888888',
      bp: '120/80',
      sugar: '90',
      weight: '70',
      height: '175',
      bmi: '22.8',
      allergies: [],
      insuranceProvider: 'Star Health',
      insurancePolicyNo: '123',
      insuranceValidTill: '2028',
      insuranceCoverage: '5L',
    );
  }

  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Delete Account Tests', () {
    late _FakeProfileRepository repo;
    late ProfileBloc bloc;

    setUp(() {
      repo = _FakeProfileRepository();
      bloc = ProfileBloc(
        getProfileUseCase: GetProfileUseCase(repo),
        updateProfileUseCase: UpdateProfileUseCase(repo),
        toggleDarkModeUseCase: ToggleDarkModeUseCase(repo),
        getFavoriteClinicsUseCase: GetFavoriteClinicsUseCase(repo),
        getUserReviewsUseCase: GetUserReviewsUseCase(repo),
        addReviewUseCase: AddReviewUseCase(repo),
        deleteReviewUseCase: DeleteReviewUseCase(repo),
        getSupportTicketsUseCase: GetSupportTicketsUseCase(repo),
        createSupportTicketUseCase: CreateSupportTicketUseCase(repo),
        sendTicketReplyUseCase: SendTicketReplyUseCase(repo),
        logoutUseCase: LogoutUseCase(repo),
        deleteAccountUseCase: DeleteAccountUseCase(repo),
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('DeleteAccountUseCase calls repository deleteAccount()', () async {
      final useCase = DeleteAccountUseCase(repo);
      await useCase();
      expect(repo.deleteAccountCalled, isTrue);
    });

    test('ProfileDeleteAccountRequested emits isLoggedOut true on success', () async {
      bloc.add(const ProfileDeleteAccountRequested());

      await expectLater(
        bloc.stream,
        emits(
          predicate<ProfileState>(
            (s) => s.isLoggedOut == true && s.successMessage != null,
          ),
        ),
      );
      expect(repo.deleteAccountCalled, isTrue);
    });

    test('ProfileDeleteAccountRequested handles requires-recent-login security error', () async {
      repo.throwOnDelete = true;
      bloc.add(const ProfileDeleteAccountRequested());

      await expectLater(
        bloc.stream,
        emits(
          predicate<ProfileState>(
            (s) =>
                s.isLoggedOut == false &&
                s.errorMessage != null &&
                s.errorMessage!.contains('sign in again'),
          ),
        ),
      );
    });
  });
}
